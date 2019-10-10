//
//  NimbleConsoleViewController.swift
//  NimbleConsole
//
//  Created by Danil Kristalev on 10/10/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

class NimbleConsoleViewController: NSViewController, ConsoleController {
  
  @IBOutlet var textView: NSTextView!
  
  @IBOutlet weak var consoleSelectionButton: NSPopUpButton!
  
  private var consolesStorage : [String: NimbleTextConsole] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.setBackgroundColor(.white)
    
  }
  
  func createConsole(title: String, show: Bool) -> Console {
    let consoleName = check(title: title)
    let newConsole = NimbleTextConsole(title: consoleName)
    consoleSelectionButton.addItem(withTitle: newConsole.title)
    if (show) {
      textView.string = newConsole.out
      consoleSelectionButton.selectItem(withTitle: newConsole.title)
    }
    consolesStorage[newConsole.title] = newConsole
    return newConsole
  }
  
  private func check(title: String) -> String {
    var count = 0
    var result = title
    while (consolesStorage[result] != nil)  {
      count = count + 1
      result = "\(title) \(count)"
    }
    return result
  }
  
  func open(console title: String) {
    guard let console = consolesStorage[title] else {
      return
    }
    consoleSelectionButton.selectItem(withTitle: console.title)
    textView.string = console.out
  }

  @IBAction func selectionDidChange(_ sender: NSPopUpButton) {
    guard let title  = sender.selectedItem?.title else {
      return
    }
    open(console: title)
  }
}

class NimbleTextConsole: Console {
  var title: String
  
  var out: String
  
  init(title: String){
    self.title = title
    self.out = title
  }
  
}


