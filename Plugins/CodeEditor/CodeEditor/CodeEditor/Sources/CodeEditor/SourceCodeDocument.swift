//
//  SourceCode.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 18.06.19.
//

import NimbleCore

public protocol SourceCodeDocument: Document {
  var languageId: String { get }
  var text: String { get }
}

public protocol SourceCodeDocumentObserver: DocumentObserver {
  func textDidChange(document: SourceCodeDocument, range: Range<Int>, lengthDelta: Int)
}

public extension SourceCodeDocumentObserver {
  func textDidChange(document: SourceCodeDocument, range: Range<Int>, lengthDelta: Int) {}
}


public protocol SourceCodeDiagnostic: Diagnostic {
  var range: Range<SourceCodePosition> { get }
}


public struct SourceCodePosition: Comparable {
  public let line: Int
  // UTF-16 offset from the line beginning
  public let offset: Int
  
  public init(line: Int, offset: Int) {
    self.line = line
    self.offset = offset
  }
  
  public static func < (lhs: SourceCodePosition, rhs: SourceCodePosition) -> Bool {
    return (lhs.line, lhs.offset) < (rhs.line, rhs.offset)
  }
}


public extension String {
  func index(at pos: SourceCodePosition) -> Int {
    return lineRange(line: pos.line).lowerBound + pos.offset
  }
  
  func range(for posRange: Range<SourceCodePosition>) -> Range<Int> {
    return index(at: posRange.lowerBound)..<index(at: posRange.upperBound)
  }
  
  func position(at index: Index) -> SourceCodePosition {
    let line = lineNumber(at: index)
    let range = lineRange(at: index)
    return SourceCodePosition(line: line, offset: distance(from: range.lowerBound, to: index))
  }
  
  func position(at offset: Int) -> SourceCodePosition {
    return position(at: index(at: offset))
  }
  
  func positionRange(for range: Range<Index>) -> Range<SourceCodePosition> {
    return position(at: range.lowerBound)..<position(at: range.upperBound)
  }
  
  func positionRange(for range: Range<Int>) -> Range<SourceCodePosition> {
    let lo = position(at: range.lowerBound)
    let hi = position(at: range.upperBound)
    return lo..<hi
  }
}
