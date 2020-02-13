//
//  NimbleConsoleViewController.swift
//  NimbleConsole
//
//  Created by Danil Kristalev on 10/10/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

class ConsoleView: NSViewController {
  
  @IBOutlet var textView: NSTextView!
  
  @IBOutlet weak var consoleSelectionButton: NSPopUpButton!
  
  @IBOutlet weak var closeButton: NSButton!
  @IBOutlet weak var clearButton: NSButton!
  
  private var consolesStorage : [String: NimbleTextConsole] = [:]
  
  private var currentConsole: Console? = nil
  
  var openedConsoles: [Console] {
    return Array(consolesStorage.values)
  }
  
  var delegate: ConsoleDelegate?
  
  private func handler(fileHandle: FileHandle, console: Console) {
    guard console.title == currentConsole?.title else {
      return
    }
    DispatchQueue.main.async {
      self.textView.string = console.contents
      self.textView.scrollToEndOfDocument(nil)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let font = NSFont.init(name: "SFMono-Medium", size: 12) {
      textView.font = font
    }
    setControllersHidden(true)
    self.textView.layoutManager?.allowsNonContiguousLayout = false
  }
  
  private func setControllersHidden(_ value: Bool){
    DispatchQueue.main.async {
      self.consoleSelectionButton.isHidden = value
      self.clearButton.isHidden = value
      self.closeButton.isHidden = value
    }
  }
  
  
  func createConsole(title: String, show: Bool) -> Console {
    let consoleName = improveName(title)
    let newConsole = NimbleTextConsole(title: consoleName, view: self)
    self.consoleSelectionButton.addItem(withTitle: newConsole.title)
    if (show) {
      self.textView.string = newConsole.contents
      self.consoleSelectionButton.selectItem(withTitle: newConsole.title)
      currentConsole = newConsole
    }
    newConsole.handler = handler(fileHandle:console:)
    newConsole.delegate = self
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
    if console.isReadingFromBuffer {
      console.handler = handler(fileHandle:console:)
    }
    consoleSelectionButton.selectItem(withTitle: console.title)
    textView.string = console.contents
  }
  
  func close(console: Console) {
    guard currentConsole?.title != console.title else {
      closeCurrentConsole(self)
      return
    }
    consolesStorage.removeValue(forKey: console.title)
    consoleSelectionButton.removeItem(withTitle: console.title)
    console.stopReadingFromBuffer()
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
    currentConsole.stopReadingFromBuffer()
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

extension ConsoleView : WorkbenchPart {
  
  var icon: NSImage? {
    return nil
  }
  
}

extension ConsoleView: ConsoleDelegate {
  func didChangeContents(console: Console){
    delegate?.didChangeContents(console: console)
    guard console.title != currentConsole?.title else {
      return
    }
    DispatchQueue.main.async {
      self.open(console: console.title)
    }
  }
}

protocol ConsoleDelegate {
  func didChangeContents(console: Console)
}

class NimbleTextConsole: Console {
  private let view: ConsoleView
  private var innerContent : Atomic<String>
  
  var contents: String {
    get {
      return innerContent.value
    }
    set {
      innerContent.modify{value in
        value = newValue
      }
    }
  }
  
  
  var title: String
  
  var output: Pipe {
    return inputPipe
  }
  
  var representedObject: Any?
  
  var inputPipe = Pipe()
  var outputPipe = Pipe()
  
  var handler: (FileHandle, Console) -> Void = {_,_ in} {
    didSet{
      outputPipe.fileHandleForReading.readabilityHandler = { fh in
        if !fh.availableData.isEmpty {
          self.handler(fh, self)
        }
      }
    }
  }
  
  fileprivate var delegate: ConsoleDelegate?
  
  var isReadingFromBuffer: Bool {
    return inputPipe.fileHandleForReading.readabilityHandler != nil
  }
  
  init(title: String, view: ConsoleView){
    self.title = title
    self.view = view
    self.innerContent = Atomic("")
    // Set up a read handler which fires when data is written to our inputPipe
    startReadingFromBuffer()
  }
  
  
  func write(data: Data) -> Console {
    if let str = String(data: data, encoding: .utf8){
      self.contents += str
    }
    self.outputPipe.fileHandleForWriting.write(data)
    return self
  }
  
  func stopReadingFromBuffer() {
    outputPipe.fileHandleForReading.readabilityHandler = nil
    inputPipe.fileHandleForReading.readabilityHandler = nil
    inputPipe = Pipe()
    outputPipe = Pipe()
  }
  
  func startReadingFromBuffer() {
    if !isReadingFromBuffer {
      contents = ""
      outputPipe.fileHandleForReading.readabilityHandler = { fh in
        self.handler(fh, self)
      }
      inputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
        guard let strongSelf = self else { return }
        
        let data = fileHandle.availableData
        if let string = String(data: data, encoding: .utf8) {
          strongSelf.contents += string
        }
        strongSelf.delegate?.didChangeContents(console: strongSelf)
        strongSelf.outputPipe.fileHandleForWriting.write(data)
      }
    }
  }
  
  func clear() {
    self.contents = ""
  }
  
  func close() {
    stopReadingFromBuffer()
    view.close(console: self)
  }
  
}

class BackgroundView: NSView {
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.wantsLayer = true
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.wantsLayer = true
  }
  
  @IBInspectable var backgrondColor: NSColor = .controlBackgroundColor
  
  override func updateLayer() {
    super.updateLayer()
    
    self.layer?.backgroundColor = backgrondColor.cgColor
  }
  
}
