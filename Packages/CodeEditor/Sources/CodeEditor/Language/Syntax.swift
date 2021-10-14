//
//  Syntax.swift
//  CodeEditorCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

// MARK: SyntaxScope

public struct SyntaxScope {
  public var value: String
  
  public init(_ value: String) {
    self.value = value
  }
  
  public init?(_ value: String?) {
    guard let val = value else { return nil }
    self.value = val
  }
  
  public func contains(_ other: SyntaxScope) -> Bool {
    return other.value.starts(with: value)
  }
}


extension SyntaxScope: Hashable {
  public static func == (lhs: SyntaxScope, rhs: SyntaxScope) -> Bool {
    return lhs.value == rhs.value
  }
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}


// MARK: SyntaxTree

public struct SyntaxNode {
  typealias NodesIndex = Array<SyntaxNode>.Index
  typealias NodesElement = Array<SyntaxNode>.Element

  var scope: SyntaxScope?
  var range: Range<Int>?
  var nodes: [SyntaxNode]

  init<T>(nodes: T) where T: Collection, T.Element == SyntaxNode {
    self.init(scope: nil, nodes: nodes)
  }

  init<T>(scope: SyntaxScope?, nodes: T) where T: Collection, T.Element == SyntaxNode {
    self.init(scope: scope, range: nodes.range, nodes: nodes)
  }

  init<T>(scope: SyntaxScope?, range: Range<Int>?, nodes: T) where T: Collection, T.Element == SyntaxNode {
    self.scope = scope
    self.range = range
    self.nodes = [SyntaxNode](nodes)
  }

  func visit(_ visitor: (SyntaxScope?, Range<Int>?) -> Void) {
    visitor(scope, range)
    nodes.visit(visitor)
  }
  
  mutating func visit(_ visitor: (inout SyntaxNode) -> Void)  {
    visitor(&self)
    nodes.visit(visitor)
  }

  func search(`in` subrange: NSRange) -> Range<NodesIndex> {
    return search(in: subrange.lowerBound..<subrange.upperBound)
  }

  func search(`in` subrange: Range<Int>) -> Range<NodesIndex> {
    let begin = search {
      guard let endIndex = $0.range?.endIndex else { return false }
      return endIndex <= subrange.startIndex
    }

    let end = search {
      guard let startIndex = $0.range?.startIndex else { return false }
      return startIndex <= subrange.endIndex
    }

    let lb = begin.result ?? begin.stop

    if let endRes = end.result, endRes < nodes.endIndex {
      return lb..<nodes.index(after: endRes)
    } else {
      return lb..<end.stop
    }
  }

  private func search(cond: (NodesElement) -> Bool) -> (result: NodesIndex?, stop: NodesIndex) {
    var begin = nodes.startIndex
    var end = nodes.endIndex

    if begin == end || (cond(nodes[nodes.index(before: end)])) {
      return (end, end)
    }

    var result: NodesIndex? = nil

    while begin != end {
      let pos = nodes.index(begin, offsetBy: nodes.distance(from: begin, to: end) / 2)
      if cond(nodes[pos]) {
        result = pos
        begin = nodes.index(after: pos)
      } else {
        end = pos
      }
    }

    return (result, begin)
  }

  mutating func replace(subrange: NSRange, with otherNodes: [SyntaxNode]) {
    replace(subrange: subrange.lowerBound..<subrange.upperBound, with: otherNodes)
  }
  
  mutating func replace(subrange: Range<Int>, with otherNodes: [SyntaxNode]) {
    let r = search(in: subrange)
    //Swift.print("Replace range: \(r) with")
    //Swift.print(otherNodes)
    nodes.replaceSubrange(r, with: otherNodes)
  }
}


extension Collection where Element == SyntaxNode {
  var range: Range<Int>? { self.compactMap{$0.range}.union() }
}

extension Array where Element == SyntaxNode {
  func visit(_ visitor: (SyntaxScope?, Range<Int>?) -> Void) {
    self.forEach { $0.visit(visitor) }
  }
  
  mutating func visit(_ visitor: (inout SyntaxNode) -> Void) {
    for i in self.indices {
      self[i].visit(visitor)
    }
  }
}


extension SyntaxNode: CustomStringConvertible {
  public var description: String {
    var printer = SyntaxTreePrinter()
    print(&printer)
    return printer.content
  }
  
  func print(_ printer: inout SyntaxTreePrinter) {
    let scope = self.scope?.value ?? ""
    
    printer << "\(range?.description ?? "empty") - \(scope)"
    
    printer.inc()
    nodes.forEach { $0.print(&printer) }
    printer.dec()
  }
}


struct SyntaxTreePrinter {
  var content: String = ""
  var indent: Int = 0
  
  mutating func inc() {
    indent += 1
  }
  
  mutating func dec() {
    if indent > 0 {
      indent -= 1
    }
  }
  
  mutating func put(_ str: String) {
    print("\(String(repeating: " ", count: 2*indent))\(str)", to: &content)
  }
  
  static func << (_ printer: inout SyntaxTreePrinter, _ str: String) {
    printer.put(str)
  }
}
