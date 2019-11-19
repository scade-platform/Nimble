//
//  ProjectOutlineView.swift
//  ProjectNavigator
//
//  Created by Grigory Markin on 15.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


open class OutlineViewController: NSViewController, WorkbenchPart {
  @IBOutlet var outlineView: NSOutlineView? = nil
  
  private var outlineDataSource: OutlineDataSource? = nil
  
  public lazy var icon: NSImage? = {
    Bundle(for: type(of: self)).image(forResource: "navigatorPart")
  }()
      
  weak var workbench: Workbench? = nil
  
  @IBAction func doubleClickedItem(_ sender: Any) {
    guard let prevDoc = outlineDataSource?.prevSelectedDocument else { return }
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

