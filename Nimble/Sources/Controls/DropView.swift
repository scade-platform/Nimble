//
//  DropView.swift
//  Nimble
//
//  Created by Danil Kristalev on 03/09/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class DropView: NSSplitView, NimbleWorkbenchView {
  lazy var acceptedTypes: [String] = {
    Array(DocumentManager.shared.typeIdentifiers.union(["public.folder"]))
  }()
  
  lazy var filteringOptions =
    [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes: acceptedTypes]
  
    
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
  }
  
  override func draggingEntered(_ info: NSDraggingInfo) -> NSDragOperation {
    let pasteboard = info.draggingPasteboard
    let accept = pasteboard.canReadObject(forClasses: [NSURL.self], options: filteringOptions)
    return accept ? .copy : NSDragOperation()
  }
  
  override func performDragOperation(_ info: NSDraggingInfo) -> Bool {
    let pasteboard = info.draggingPasteboard
    if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: filteringOptions) as? [URL], urls.count > 0 {
      urls.forEach {
        NSDocumentController.shared.openDocument(withContentsOf: $0, display: true,
                                                 completionHandler: NimbleController.openDocumentHandler)
      }
      //workbench?.openAll(urls)
      return true
    }
    return false
  }
}

