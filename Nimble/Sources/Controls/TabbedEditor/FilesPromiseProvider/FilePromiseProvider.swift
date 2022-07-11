//
//  FilePromiseProvider.swift
//  Nimble
//
//  Created by Danil Kristalev on 11.07.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Foundation
import AppKit

class FilePromiseProvider: NSFilePromiseProvider {
  struct UserInfoKeys {
      static let indexPathKey = "indexPath"
  }

  override func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
      var types = super.writableTypes(for: pasteboard)
      types.append(.tabDragType) // Add our own internal drag type (row drag and drop reordering).
      return types
  }

  override func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
      guard let userInfoDict = userInfo as? [String: Any] else { return nil }
      switch type {
      case .tabDragType:
          let indexPathData = userInfoDict[FilePromiseProvider.UserInfoKeys.indexPathKey]
          return indexPathData
      default:
          break
      }
      return super.pasteboardPropertyList(forType: type)
  }

  public override func writingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard)
      -> NSPasteboard.WritingOptions {
      return super.writingOptions(forType: type, pasteboard: pasteboard)
  }
}
