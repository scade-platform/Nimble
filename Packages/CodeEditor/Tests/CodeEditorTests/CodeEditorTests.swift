//
//  CodeEditorTests.swift
//  
//
//  Created by Grigory Markin on 01.10.23.
//

import XCTest
import Path

@testable import CodeEditor

final class CodeEditorTests: XCTestCase {
  lazy var path = Path(#filePath)!
  lazy var testFilePath = Path("/Users/markin/Desktop/nimble-test/foo3.swift")!

  lazy var grammar: LanguageGrammar =
    LanguageGrammar(scopeName: "swift", path: path.parent.parent.parent/"swift/swift.tmLanguage.json")

  func testTMTokenizer() throws {
    guard let content = try? String(contentsOf: self.testFilePath) else {
      XCTFail()         
      return
    }

    let res = grammar.tokenizer?.tokenize(content)
    res?.nodes.forEach{
      Swift.print("\($0.range.lowerBound)..<\($0.range.upperBound) - \($0.data?.value ?? "")")
    }
  }
}
