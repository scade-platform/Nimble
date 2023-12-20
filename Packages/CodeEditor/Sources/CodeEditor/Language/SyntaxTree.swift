//
//  SyntaxTree.swift
//  CodeEditorCore
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



// MARK: - SyntaxTree

public typealias SyntaxTree = IntervalTree<SyntaxScope, Int>
public typealias SyntaxNode = SyntaxTree.Node


// MARK: - SyntaxScope

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



// MARK: - Extensions

extension Array where Element == SyntaxNode {
  var range: Range<Int>? { self.compactMap{$0.range}.union() }
}

