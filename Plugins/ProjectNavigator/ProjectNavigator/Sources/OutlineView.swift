//
//  ProjectOutlineView.swift
//  ProjectNavigator
//
//  Created by Grigory Markin on 15.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
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
      
  weak var workbench: Workbench? = nil {
    didSet {
      workbench?.add(workbenchObserver: self)
    }
    willSet {
      workbench?.remove(workbenchObserver: self)
    }
  }
  
  @IBAction func itemClicked(_ sender: Any) {
    guard let outlineView = outlineView,
          let item = outlineView.item(atRow: outlineView.selectedRow) as? File else { return }
        
    prevSelectedDocument = workbench?.currentDocument
    
    NSDocumentController.shared.openDocument(withContentsOf: item.url, display: false) { [weak self] doc, _, _ in
        guard let doc = doc as? Document else { return }
      self?.workbench?.open(doc, show: true, openNewEditor: false)
    }
  }
  
  @IBAction func itemDoubleClicked(_ sender: Any) {
    guard let prevDoc = prevSelectedDocument else { return }
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
}


extension OutlineView: WorkbenchObserver {
  public func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?) {
    
  }
}
