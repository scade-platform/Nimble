//
//  ImageViewerController.swift
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

import Cocoa
import NimbleCore

class ImageViewerController: NSViewController {
  @IBOutlet
  weak var imageView: NSImageView? = nil
  
  weak var doc: ImageDocument? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView?.image = doc?.image
  }
}

extension ImageViewerController: WorkbenchEditor {}
