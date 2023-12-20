//
//  IntervalTreeTests.swift
//  
//
//  Created by Grigory Markin on 01.12.23.
//

import XCTest

@testable import CodeEditor

final class IntervalTreeTests: XCTestCase {
  typealias Tree = IntervalTree<Int, Int>

  var tree = Tree()
  
  func testEmpty() throws {
    XCTAssertTrue(tree.isEmpty)
    XCTAssertEqual("\(tree)", "")
  }

  func testInsert() throws {
    tree.insert(5..<10)

    XCTAssertFalse(tree.isEmpty)
    XCTAssertEqual("\(tree)", "[5,10,10]")

    tree.insert(15..<25)
    XCTAssertEqual("\(tree)", "[5,10,25][15,25,25]")

    tree.insert(1..<12)
    XCTAssertEqual("\(tree)", "[1,12,12][5,10,25][15,25,25]")

    tree.insert(8..<16)
    XCTAssertEqual("\(tree)", "[1,12,12][5,10,25][8,16,16][15,25,25]")

    tree.insert(14..<20)
    XCTAssertEqual("\(tree)", "[1,12,12][5,10,25][8,16,20][14,20,20][15,25,25]")

    tree.insert(2..<13)
    XCTAssertEqual("\(tree)", "[1,12,13][2,13,13][5,10,25][8,16,20][14,20,20][15,25,25]")
  }

  func testDelete() throws {
    tree.insert(5..<10)

    XCTAssertEqual(tree.delete(0..<5), [])
    XCTAssertFalse(tree.isEmpty)

    XCTAssertEqual(tree.delete(0..<6), [5..<10])
    XCTAssertTrue(tree.isEmpty)

    tree.insert(5..<10)
    tree.insert(3..<8)
    tree.insert(15..<20)
    XCTAssertEqual("\(tree)", "[3,8,8][5,10,20][15,20,20]")

    XCTAssertEqual(tree.delete(0..<4), [3..<8])
    XCTAssertEqual("\(tree)", "[5,10,20][15,20,20]")

    tree.insert(3..<8)
    XCTAssertEqual("\(tree)", "[3,8,8][5,10,20][15,20,20]")


    XCTAssertEqual(tree.delete(8..<10), [5..<10])
    XCTAssertEqual("\(tree)", "[3,8,20][15,20,20]")

    XCTAssertEqual(tree.delete(0..<4), [3..<8])
    XCTAssertEqual("\(tree)", "[15,20,20]")

    tree.insert(5..<10)
    tree.insert(20..<25)
    XCTAssertEqual("\(tree)", "[5,10,10][15,20,25][20,25,25]")

    XCTAssertEqual(tree.delete(20..<25), [20..<25])
    XCTAssertEqual("\(tree)", "[5,10,10][15,20,20]")

    tree.insert(20..<25)
    XCTAssertEqual("\(tree)", "[5,10,10][15,20,25][20,25,25]")

    XCTAssertEqual(tree.delete(5..<20), [5..<10, 15..<20])
    XCTAssertEqual("\(tree)", "[20,25,25]")
  }

  
  func testOverlaps() throws {
    XCTAssertEqual(tree.overlaps(3..<4), [])

    tree.insert(15..<25)

    XCTAssertEqual(tree.overlaps(3..<4), [])
    XCTAssertEqual(tree.overlaps(3..<15), [])
    XCTAssertEqual(tree.overlaps(3..<16), [15..<25])

    tree.insert(1..<12)

    XCTAssertEqual(tree.overlaps(3..<4), [1..<12])
    XCTAssertEqual(tree.overlaps(3..<16), [1..<12, 15..<25])

    tree.insert(8..<14)

    XCTAssertEqual(tree.overlaps(3..<4), [1..<12])
    XCTAssertEqual(tree.overlaps(3..<16), [1..<12, 8..<14, 15..<25])
    XCTAssertEqual(tree.overlaps(14..<15), [])
    XCTAssertEqual(tree.overlaps(14..<16), [15..<25])

    tree.insert(18..<20)
    XCTAssertEqual(tree.overlaps(14..<20), [15..<25, 18..<20])
  }

  
}
