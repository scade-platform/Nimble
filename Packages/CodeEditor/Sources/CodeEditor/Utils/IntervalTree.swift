//
//  IntervalTree.swift
//  CodeEditor
//
//  Copyright © 2023 SCADE Inc. All rights reserved.
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


// MARK: - IntervalNode


public class IntervalNode<Element, Bound> where Bound: Comparable {
  public typealias Element = Element

  public private(set) var range: Range<Bound>
  public private(set) var data: Element?

  public fileprivate(set) var max: Bound
  public fileprivate(set) var left: IntervalNode?
  public fileprivate(set) var right: IntervalNode?

  public init(range: Range<Bound>, data: Element? = nil) {
    self.range = range
    self.data = data

    self.max = range.upperBound
  }
}


// MARK: - IntervalTree

public struct IntervalTree<Element, Bound> where Bound: Comparable {
  public typealias Node = IntervalNode<Element, Bound>

  public private(set) var root: Node? = nil

  public var isEmpty: Bool { root == nil }

  public init() {}

  public mutating func insert(_ node: Node) {
    if let root = root {
      IntervalTree.insert(node, to: root)
    } else {
      self.root = node
    }
  }

  public mutating func delete(_ range: Range<Bound>) -> [Node] {
    guard let root = self.root else {
      return []
    }

    let res = IntervalTree.delete(range, from:  root)
    self.root = res.0

    return res.1
  }


  public func overlaps(_ range: Range<Bound>) -> [Node] {
    guard let root = self.root else { return [] }
    return IntervalTree.overlaps(range, with: root)
  }


  private static func insert(_ node: Node, to dst: Node) {
    dst.max = max(dst.max, node.range.upperBound)

    if dst.range.lowerBound < node.range.lowerBound {
      if let right = dst.right {
        insert(node, to: right)
      } else {
        dst.right = node
      }

    } else {
      if let left = dst.left {
        insert(node, to: left)
      } else {
        dst.left = node
      }
    }
  }

  private static func delete(_ range: Range<Bound>, from src: Node) -> (Node?, [Node]) {
    var deleted = [Node]()

    if let left = src.left, left.max >= range.lowerBound {
      let del = delete(range, from: left)

      src.left = del.0
      deleted.append(contentsOf: del.1)
    }

    if let right = src.right, right.range.lowerBound < range.upperBound {
      let del = delete(range, from: right)

      src.right = del.0
      deleted.append(contentsOf: del.1)
    }

    src.max = max(src.left?.max ?? src.range.upperBound , src.right?.max ?? src.range.upperBound, src.range.upperBound)

    if src.range.overlaps(range) {
      deleted.append(src)
      return (delete(src), deleted)
    }

    return (src, deleted)
  }

  private static func delete(_ node: Node) -> Node? {
    if let left = node.left {
      if let right = node.right {
        // Left and Right
        node.left = left.left
        node.right = left.right

        left.right = right
        left.left = delete(node)

        left.max = max(left.max, right.max)

      } else {
        // Left only

        node.left = left.left
        node.right = left.right

        left.left = delete(node)
      }

      return left

    } else if let right = node.right {
      // Right only

      node.left = right.left
      node.right = right.right

      right.right = delete(node)
      return right

    } else {
      return nil
    }
  }


  private static func overlaps(_ range: Range<Bound>, with node: Node) -> [Node] {
    var res = [Node]()

    if let left = node.left, left.max >= range.lowerBound {
      res.append(contentsOf: overlaps(range, with: left))
    }

    if node.range.overlaps(range) {
      res.append(node)
    }

    if let right = node.right, right.range.lowerBound < range.upperBound {
      res.append(contentsOf: overlaps(range, with: right))
    }

    return res
  }

  private static func swap(_ n1: Node, n2: Node) {


  }

}

// MARK: - IntervalNode + Helpers

public extension IntervalNode {
  func with(range: Range<Bound>) -> IntervalNode {
    return IntervalNode(range: range, data: self.data)
  }

  func with(offset: Bound) -> IntervalNode where Bound: Numeric {
    return IntervalNode(range: self.range.offset(by: offset), data: self.data)
  }

  func with(data: Element?) -> IntervalNode {
    return IntervalNode(range: self.range, data: data)
  }
}

// MARK: - IntervalTree + Helpers

public extension IntervalTree {

  // Insertion

  mutating func insert<T>(_ nodes: T) where T: Collection, T.Element: Node {
    nodes.forEach{self.insert($0)}
  }

  mutating func insert(_ range: Range<Bound>, data: Node.Element? = nil) {
    self.insert(Node(range: range, data: data))
  }

  mutating func insert<T>(_ ranges: T) where T: Collection, T.Element == (Range<Bound>, Node.Element?) {
    self.insert(ranges.map{Node(range: $0.0, data: $0.1)})
  }

  mutating func insert<T>(_ ranges: T) where T: Collection, T.Element == Range<Bound> {
    self.insert(ranges.map{Node(range: $0)})
  }

  // Removal

  mutating func delete(_ range: Range<Bound>) -> [Range<Bound>] {
    return self.delete(range).map{$0.range}
  }

  mutating func delete<T>(_ ranges: T) -> [Range<Bound>] where T: Collection, T.Element == Range<Bound> {
    ranges.reduce([]){ $0 + self.delete($1) }
  }

  // Queries

  func overlaps(_ range: Range<Bound>) -> [Range<Bound>] {
    return self.overlaps(range).map{$0.range}
  }
}



// MARK: - IntervalTree + CustomStringConvertible

extension IntervalNode: CustomStringConvertible {
  public var description: String {
    return "[\(range.lowerBound),\(range.upperBound),\(max)]"
  }
}


extension IntervalTree: CustomStringConvertible {
  private static func print(node: Node) -> String {
    var desc = "\(node)"

    if let left = node.left {
      desc = "\(print(node: left))\(desc)"
    }

    if let right = node.right {
      desc = "\(desc)\(print(node: right))"
    }

    return desc
  }

  public var description: String {
    guard let root = self.root else { return "" }
    return IntervalTree.print(node: root)
  }
}
