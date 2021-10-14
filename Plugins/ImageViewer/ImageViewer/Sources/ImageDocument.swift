//
//  ImageDocument.swift
//  ImageViewer
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
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

import AppKit
import NimbleCore

public final class ImageDocument: NimbleDocument {
  var image: NSImage?
  
  private lazy var viewer: ImageViewerController = {
    let controller = ImageViewerController.loadFromNib()
    controller.doc = self
    return controller
  }()
      
  public static func isDefault(for uti: String) -> Bool {
    return canOpen(uti)
  }
  
  public override func read(from data: Data, ofType typeName: String) throws {
    image = NSImage(data: data)
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
}


extension ImageDocument: Document {
  public var editor: WorkbenchEditor? { return viewer }
  public static var typeIdentifiers: [String] { NSImage.imageTypes }
}
