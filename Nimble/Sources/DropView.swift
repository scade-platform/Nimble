//
//  DropView.swift
//  Nimble
//
//  Created by Danil Kristalev on 03/09/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class DropView : NSSplitView {
  var expectedUTI : Set<String> {
    return DocumentManager.shared.documentUTI
  }
  
  var dragCache : DragСache? = nil
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    if checkExtension(sender) {
      return .copy
    } else {
      return NSDragOperation()
    }
  }
  
  func checkExtension(_ info : NSDraggingInfo) -> Bool {
    guard let board = info.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray else {
      return false
    }
    let openableURL = getOpenableURL(board)
    guard let result = openableURL else {
      return false
    }
    dragCache = DragСache(opensURL: result, dragInfo: info)
    return true
  }
  
  private func getOpenableURL(_ source: NSArray) -> [URL]? {
    let filesURL = source.compactMap{$0 as? String}.map{URL(fileURLWithPath: $0)}
    let predicate: (URL) -> Bool = { url in
      self.expectedUTI.contains{uti in
        let sourceUTI = self.getUTI(url)
        return UTTypeConformsTo(sourceUTI as CFString , uti as CFString)
      }
    }
    let openURL = filesURL.filter{predicate($0)}
    guard !openURL.isEmpty else { return nil }
    return openURL
  }
  
  func getUTI(_ url: URL) -> String {
    if let resourceValues = try? url.resourceValues(forKeys: [.typeIdentifierKey]),
      let uti = resourceValues.typeIdentifier {
      return uti
    }
    return ""
  }
  
  
  
  
  override func performDragOperation(_ info: NSDraggingInfo) -> Bool {
    guard let board = info.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray else {
      return false
    }
    let openableURL: [URL]
    if let cache = dragCache, cache.dragInfo === info, !cache.opensURL.isEmpty {
      openableURL = cache.opensURL
    }else{
      openableURL = getOpenableURL(board) ?? []
    }
    guard let windowController = NSDocumentController.shared.currentDocument?.windowControllers.first(where: {$0 is NimbleWorkbench}), let workbench = windowController as? NimbleWorkbench else {
      return false
    }
//    workbench.project?.openAll(fileSystemElements: openableURL)
    return true
  }
  
  
  struct DragСache {
    let opensURL : [URL]
    let dragInfo : NSDraggingInfo
  }
}

