//
//  NimbleConsoleViewController.swift
//  NimbleConsole
//
//  Created by Danil Kristalev on 10/10/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

class ConsoleViewController: NSViewController {
  
  @IBOutlet var textView: NSTextView!
  
  @IBOutlet weak var consoleSelectionButton: NSPopUpButton!
  
  @IBOutlet weak var closeButton: NSButton!
  @IBOutlet weak var clearButton: NSButton!
  
  private var consolesStorage : [String: NimbleTextConsole] = [:]
  
  private var currentConsole: Console? = nil
  
  private func handler(fileHandle: FileHandle, console: Console) {
    guard console.title == currentConsole?.title else {
      return
    }
    handler(fileHandle: fileHandle)
  }
  
  private func handler(fileHandle: FileHandle) {
    let data = fileHandle.availableData
    if let string = String(data: data, encoding: String.Encoding.utf8) {
      DispatchQueue.main.async {
        self.textView.string += string
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.setBackgroundColor(.white)
    setControllersHidden(true)
  }
  
  func setControllersHidden(_ value: Bool){
    DispatchQueue.main.async {
      self.consoleSelectionButton.isHidden = value
      self.clearButton.isHidden = value
      self.closeButton.isHidden = value
    }
  }
  
  
  func createConsole(title: String, show: Bool) -> Console {
    let consoleName = improveName(title)
    let newConsole = NimbleTextConsole(title: consoleName)
    DispatchQueue.main.async {
      self.consoleSelectionButton.addItem(withTitle: newConsole.title)
    }
    if (show) {
      DispatchQueue.main.async {
        self.textView.string = newConsole.contents
        self.consoleSelectionButton.selectItem(withTitle: newConsole.title)
      }
      currentConsole = newConsole
    }
    newConsole.handler = handler(fileHandle:console:)
    consolesStorage[newConsole.title] = newConsole
    setControllersHidden(false)
    return newConsole
  }
  
  private func improveName(_ title: String) -> String {
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
    currentConsole = console
    console.handler = handler(fileHandle:console:)
    consoleSelectionButton.selectItem(withTitle: console.title)
    textView.string = console.contents
  }
  
  @IBAction func selectionDidChange(_ sender: NSPopUpButton) {
    guard let title  = sender.selectedItem?.title else {
      return
    }
    open(console: title)
  }
  
  @IBAction func closeCurrentConsole(_ sender: Any) {
    guard let currentConsole = currentConsole as? NimbleTextConsole else {
      return
    }
    consolesStorage.removeValue(forKey: currentConsole.title)
    consoleSelectionButton.removeItem(withTitle: currentConsole.title)
    currentConsole.close()
    textView.string = ""
    if !consolesStorage.isEmpty{
       open(console: consolesStorage.keys.first ?? "")
    }else{
      setControllersHidden(true)
    }
  }
  
  @IBAction func clearCurrentConsole(_ sender: Any) {
    guard let currentConsole = currentConsole as? NimbleTextConsole else {
      return
    }
    currentConsole.clear()
    textView.string = currentConsole.contents
  }
  
}

extension ConsoleViewController : WorkbenchPart {
  
  var icon: NSImage? {
    return nil
  }
  
  
}

class NimbleTextConsole: Console {
  
  private let queue = DispatchQueue(label: "com.scade.nimble.consoleBuffer")
  private var innerContent : String
  
  var contents: String {
    get {
      return queue.sync { innerContent }
    }
    set {
      queue.sync { [weak self] in
        self?.innerContent = newValue
      }
    }
  }
  
  
  var title: String
  
  var output: Pipe {
    return inputPipe
  }
  
  let inputPipe = Pipe()
  let outputPipe = Pipe()
  
  var handler: (FileHandle, Console) -> Void = {_,_ in} {
    didSet{
      outputPipe.fileHandleForReading.readabilityHandler = { fh in
        self.handler(fh, self)
      }
    }
  }
  
  init(title: String){
    self.title = title
    self.innerContent = ""
    // Set up a read handler which fires when data is written to our inputPipe
    inputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
      guard let strongSelf = self else { return }
      
      let data = fileHandle.availableData
      if let string = String(data: data, encoding: .utf8) {
        strongSelf.contents += string
      }
      strongSelf.outputPipe.fileHandleForWriting.write(data)
    }
  }
  
  
  func write(data: Data) -> Console {
    if let str = String(data: data, encoding: .utf8){
      self.contents += str
    }
    self.outputPipe.fileHandleForWriting.write(data)
    return self
  }
  
  func close() {
    outputPipe.fileHandleForReading.readabilityHandler = nil
    inputPipe.fileHandleForReading.readabilityHandler = nil
  }
  
  func clear() {
    self.contents = ""
  }
  
}


