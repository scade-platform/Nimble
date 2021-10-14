//
//  DropView.swift
//  Nimble
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
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

import Cocoa
import NimbleCore

class DropView: NSSplitView, WorkbenchView {
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
            
    guard let controller = NSDocumentController.shared as? NimbleController,
          let workbench = self.window?.windowController as? NimbleWorkbench,
          let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: filteringOptions) as? [URL] else {
      return false
    }

    urls.forEach {
      controller.open(url: $0, in: workbench)
    }
    
    return false
  }
}

