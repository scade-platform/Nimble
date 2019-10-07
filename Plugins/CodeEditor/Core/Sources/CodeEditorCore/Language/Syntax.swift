//
//  Syntax.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 04.10.19.
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
  let scope: SyntaxScope?
  let range: Range<Int>
  let nodes: [SyntaxNode]
  
  func visit(_ visitor: (SyntaxScope?, Range<Int>) -> Void) {
    visitor(scope, range)
    nodes.visit(visitor)
  }
}


extension Array where Element == SyntaxNode {
  func visit(_ visitor: (SyntaxScope?, Range<Int>) -> Void) {
    self.forEach { $0.visit(visitor) }
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
    
    printer << "\(range) - \(scope)"
    
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
