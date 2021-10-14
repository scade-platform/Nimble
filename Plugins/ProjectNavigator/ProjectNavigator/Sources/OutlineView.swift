//
//  ProjectOutlineView.swift
//  ProjectNavigator
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


open class OutlineView: NSViewController, WorkbenchPart {
  @IBOutlet var outlineView: NSOutlineView? = nil
  
  private var prevSelectedDocument: Document? = nil
  
  private var outlineDataSource: OutlineDataSource? = nil
  
  public lazy var icon: NSImage? = {
    Bundle(for: type(of: self)).image(forResource: "navigatorPart")
  }()
      
  public weak var workbench: Workbench? = nil {
    didSet {
      workbench?.observers.add(observer: self)
    }
    willSet {
      workbench?.observers.remove(observer: self)
    }
  }
  
  var selectedItem: Any? {
    guard let outlineView = outlineView else { return nil }
    return outlineView.item(atRow: outlineView.selectedRow)
  }
  
  @IBAction func itemClicked(_ sender: Any) {
    if selectedItem is FolderItem {
      outlineView?.expandItem(selectedItem)
      return
    }
    
    guard let item = selectedItem as? File else { return }
    prevSelectedDocument = workbench?.currentDocument
    
    NSDocumentController.shared.openDocument(withContentsOf: item.url, display: false) { [weak self] doc, _, _ in
        guard let doc = doc as? Document else { return }
      self?.workbench?.open(doc, show: true, openNewEditor: false)
    }
  }
  
  @IBAction func itemDoubleClicked(_ sender: Any) {
    guard selectedItem is File, let prevDoc = prevSelectedDocument else { return }
    workbench?.open(prevDoc, show: false)
  }
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Project"
        
    guard let workbench = workbench,
          let outlineView = outlineView else { return }
                            
    outlineDataSource = OutlineDataSource(outlineView, for: workbench)
        
    outlineView.delegate = outlineDataSource
    outlineView.dataSource = outlineDataSource
        
    outlineView.floatsGroupRows = false
    
    outlineView.expandItem(outlineDataSource?.openedDocuments)
    
  }
  
  open override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)
    guard let outlineView = outlineView,
      let outlineDataSource = outlineDataSource,
      outlineView.isItemExpanded(outlineDataSource.projectFolders) else { return }
    var expandedFolders: [String] = []
    var stack: [FolderItem] = outlineDataSource.projectFolders.folders
    repeat {
      // Pop an item off the stack
      let currentItem = stack.last
      if !stack.isEmpty{
        stack = stack.dropLast()
      }
      
      // Push the children onto the stack
      if outlineView.isItemExpanded(currentItem) {
        let childCount = outlineView.numberOfChildren(ofItem: currentItem)
        for i in 0..<childCount {
          if let obj = outlineView.child(i, ofItem: currentItem) as? FolderItem {
              stack.append(obj)
          }
        }
        
        // Visit the current item.
        if let folderItem = currentItem {
          expandedFolders.append(folderItem.folder.path.string)
        }
      }
      
    } while !stack.isEmpty
    coder.encode(expandedFolders, forKey: "expandedFolders")
  }
  
  open override func restoreState(with coder: NSCoder) {
    super.restoreState(with: coder)
    guard let outlineView = outlineView,
         let outlineDataSource = outlineDataSource,
         outlineView.isItemExpanded(outlineDataSource.projectFolders) else { return }
    if let expandedFolders = coder.decodeObject(forKey: "expandedFolders") as? [String] {
      var stack: [FolderItem] = outlineDataSource.projectFolders.folders
      repeat {
        // Pop an item off the stack
        let currentItem = stack.last
        if !stack.isEmpty{
          stack = stack.dropLast()
        }
        
        // Push the children onto the stack
        if let folderItem = currentItem, expandedFolders.contains(folderItem.folder.path.string) {
          outlineView.expandItem(folderItem)
          let childCount = outlineView.numberOfChildren(ofItem: folderItem)
          for i in 0..<childCount {
            if let obj = outlineView.child(i, ofItem: currentItem) as? FolderItem {
                stack.append(obj)
            }
          }
        }
        
      } while !stack.isEmpty
    }
  }
}


extension OutlineView: WorkbenchObserver {
  public func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?) {
    
  }
}
