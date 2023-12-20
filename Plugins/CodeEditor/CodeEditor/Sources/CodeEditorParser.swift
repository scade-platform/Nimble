//
//  CodeEditorParser.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 22.07.23.
//  Copyright © 2023 SCADE. All rights reserved.
//

import Foundation
import CodeEditor

actor CodeEditorParser {
  typealias Tokenizer = (SourceCodeDocument, Range<Int>) -> [SyntaxNode]
  typealias TokenizerTask = Task<[SyntaxNode]?, Never>

  private weak var document: CodeEditorDocument?

  private var tokenizers: [Tokenizer]
  private var syntaxTree: SyntaxTree = SyntaxTree()

  private var tasks: [(Range<Int>, Int, TokenizerTask)] = []
  private var waiting: CheckedContinuation<Void, Never>? = nil

  private var executor: Task<(), Never>? = nil

  lazy var results: AsyncStream<(Range<Int>, [SyntaxNode])> = {
    return .init { cont in

      let executor = Task {
        while !Task.isCancelled  {
          if self.tasks.count > 0 {
            guard let res = await self.executeNext() else { continue }
            cont.yield(res)

          } else {
            // Wait for tasks (waiting is cancellable)
            let cancel_waiting = {
              self.waiting?.resume()
              self.waiting = nil
            }

            await withTaskCancellationHandler {
              await withCheckedContinuation {cont in
                waiting = cont
              }
            } onCancel: { [waiting] in
              cancel_waiting()
            }
          }
        }
        cont.finish()
      }

      cont.onTermination = { @Sendable _ in
        executor.cancel()
      }

      self.executor = executor
    }
  }()


  init(document: CodeEditorDocument, tokenizers: [Tokenizer]) {
    self.document = document
    self.tokenizers = tokenizers
  }


  func invalidate(range: Range<Int>, changeInLength delta: Int) { //async {
    guard let doc = document else { return }

    var dirtyRange = invalidateTasks(range: range, changeInLength: delta)
    dirtyRange = invalidateSyntaxTree(range: dirtyRange, changeInLength: delta)

    // Adjust dirty range
    dirtyRange = dirtyRange.lowerBound..<dirtyRange.upperBound + delta

    tokenizers.forEach { tokenize in
      let t: TokenizerTask = Task.detached { [dirtyRange] in
        print("Start tokenize")

        var nodes: [SyntaxNode] = []

        if #available(macOS 13.0, *) {
          let clock = ContinuousClock()
          let elapsed = clock.measure {
            nodes = tokenize(doc, dirtyRange)
          }
          print("End tokenize: \(elapsed)")

        } else {
          nodes = tokenize(doc, dirtyRange)
          print("End tokenize")
        }

        if !Task.isCancelled {
          return nodes

        } else {
          print("Task was cancelled")
          return nil
        }
      }

      print("Invalidate: \(range) Dirty: \(dirtyRange)")

      tasks.append((dirtyRange, 0, t))
      self.resume()
    }
  }

  /// Invalidate running tasks and returns a 'dirtyRange' that has to be invalidated
  private func invalidateTasks(range: Range<Int>, changeInLength delta: Int) -> Range<Int> {
    // Dirty range before edit
    var dirtyRange = range.lowerBound..<range.upperBound - delta

    // Update running tasks
    for i in tasks.indices {
      let (r, o, t) = tasks[i]

      // If a task has been already cancelled, just ignore
      guard !t.isCancelled else { continue }

      let tr = r.offset(by: o)

      // Check the running tasks's range:
      if let _ = tr.intersection(with: dirtyRange) {
        // If it intersects with the dirty range, cancel the task and enlarge the dirty range
        dirtyRange = dirtyRange.union(with: tr)
        print("Cancel task with range: \(tr)")
        t.cancel()

      } else if dirtyRange.upperBound < tr.lowerBound {
        // Else, adjust an offset if the running task processes a range beyod the dirty range
        tasks[i] = (r, o + delta, t)
      }
    }

    return dirtyRange
  }

  /// Invalidate syntax tree returns a 'dirtyRange' that has to be invalidated
  private func invalidateSyntaxTree(range: Range<Int>, changeInLength delta: Int) -> Range<Int> {
    var dirtyRange: Range<Int>

    if let delRange = self.syntaxTree.delete(range).union() {
      dirtyRange = range.union(with: delRange)
    } else {
      dirtyRange = range
    }

    if let upperBound = self.syntaxTree.root?.max {
      ///TODO: investigate if offsetting nodes beyond the dirtyRange can be done more efficiently, i.e. without deletion/insertion
      let offsetNodes: [SyntaxNode] = self.syntaxTree.delete(dirtyRange.upperBound..<upperBound)

      offsetNodes.forEach{
        self.syntaxTree.insert($0.range.offset(by: delta), data: $0.data)
      }
    }

    return dirtyRange
  }

  private func resume() {
    self.waiting?.resume()
    self.waiting = nil
  }

  private func executeNext() async -> (Range<Int>, [SyntaxNode])? {
    var (range, offset, task) = tasks.removeFirst()

    guard var nodes = await task.value else { return nil }

    print("Updating \(range) with offset \(offset)")

    guard !nodes.isEmpty else { return (range, nodes) }

    // Adjust nodes w.r.t the offset
    if offset > 0 {
      nodes = nodes.map{$0.with(offset: offset)}
      range = range.offset(by: offset)
    }

    self.syntaxTree.insert(nodes)
    return (range, nodes)
  }
}
