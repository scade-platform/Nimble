//
//  NSTableView.swift
//  NimbleCore
//
//  Created by Grigory Markin on 03/09/2020.
//


import Cocoa

public extension NSTableView {
  func makeCell(id: String) -> NSTableCellView? {
    return makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: nil) as? NSTableCellView
  }
}
