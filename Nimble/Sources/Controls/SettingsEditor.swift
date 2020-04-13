//
//  SettingsEditor.swift
//  Nimble
//
//  Created by Grigory Markin on 21.03.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class SettingsEditor: NSViewController {
  @IBOutlet weak var tableView: NSTableView!
  
  weak var settings: Settings? = nil {
    didSet {
      tableView.reloadData()
    }
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
}


// MARK: - WorkbenchEditor
extension SettingsEditor: WorkbenchEditor {}


// MARK: - NSTableViewSectionDataSource

protocol NSTableViewSectionDataSource: NSTableViewDataSource {
  func numberOfSections(in tableView: NSTableView) -> Int
  func tableView(tableView: NSTableView, numberOfRowsInSection section: Int) -> Int
}


extension NSTableViewSectionDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return (0..<self.numberOfSections(in: tableView)).reduce(0){
      return $0 + self.tableView(tableView: tableView, numberOfRowsInSection: $1) + 1
    }
  }
  
  func tableView(tableView: NSTableView, sectionForRow row: Int) -> (section: Int, row: Int) {
    var allRows = 0
    for i in 0..<self.numberOfSections(in: tableView) {
      let sectionRows = self.tableView(tableView: tableView, numberOfRowsInSection: i) + 1
      if row < allRows + sectionRows {
        return (section: i, row: row - allRows)
      }
      allRows += sectionRows
    }
    return (0, 0)
  }
}


extension SettingsEditor: NSTableViewDataSource {
  
}
