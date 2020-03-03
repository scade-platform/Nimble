//
//  NimbleConsoleViewController.swift
//  NimbleConsole
//
//  Created by Danil Kristalev on 10/10/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore
import Ansi

class ConsoleView: NSViewController {
  
  @IBOutlet var textView: NSTextView!
  
  @IBOutlet weak var consoleSelectionButton: NSPopUpButton!
  
  @IBOutlet weak var closeButton: NSButton!
  @IBOutlet weak var clearButton: NSButton!
  
  private var consolesStorage : [String: NimbleTextConsole] = [:]
  
  private var currentConsole: Console? = nil
  
  private lazy var font = {
    return NSFont.init(name: "SFMono-Medium", size: 12) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
  }()

  
  var openedConsoles: [Console] {
    return Array(consolesStorage.values)
  }
  
  private func handler(data: Data, console: Console) {
    if let string = String(data: data, encoding: .utf8) {
      DispatchQueue.main.async { [weak self] in
        guard let strongSelf = self else { return }
        if string.isEmpty {
          strongSelf.textView.string = ""
        }
        if console.title != strongSelf.currentConsole?.title {
          strongSelf.open(console: console.title)
        } else {
          if strongSelf.textView.string.suffix(string.count) != string {
            strongSelf.textView.textStorage?.append(strongSelf.convertToAttributedString(string))
            strongSelf.textView.scrollToEndOfDocument(nil)
          }
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    textView.font = font
    setControllersHidden(true)
    self.textView.layoutManager?.allowsNonContiguousLayout = false
  }
  
  private func setControllersHidden(_ value: Bool){
    DispatchQueue.main.async { [weak self] in
      self?.consoleSelectionButton.isHidden = value
      self?.clearButton.isHidden = value
      self?.closeButton.isHidden = value
    }
  }
  
  private func convertToAttributedString(_ string: String) -> NSAttributedString {
    do {
      return try string.ansified(font: self.font, color: NSColor.textColor)
    } catch {
      let attrs = [
        NSAttributedString.Key.font: self.font,
        NSAttributedString.Key.foregroundColor: NSColor.textColor
        
      ]
      return NSAttributedString(string: string, attributes: attrs)
    }
  }
  
  func createConsole(title: String, show: Bool, startReading: Bool) -> Console {
    let consoleName = improveName(title)
    let newConsole = NimbleTextConsole(title: consoleName, view: self, startReading: startReading)
    self.consoleSelectionButton.addItem(withTitle: newConsole.title)
    if (show) {
      self.textView.string = ""
      self.textView.textStorage?.append(convertToAttributedString(newConsole.contents))
      self.consoleSelectionButton.selectItem(withTitle: newConsole.title)
      newConsole.handler = handler(data:console:)
      currentConsole = newConsole
    }
    if currentConsole == nil {
      currentConsole = newConsole
    }
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
    guard let console = consolesStorage[title], console.title != currentConsole?.title else {
      return
    }
    currentConsole = console
    textView.string = ""
    self.textView.textStorage?.append(convertToAttributedString(console.contents))
    if console.isReadingFromBuffer {
      console.handler = handler(data:console:)
    } 
    consoleSelectionButton.selectItem(withTitle: console.title)
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
      self.currentConsole = nil
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
  
  var handler: (Data, Console) -> Void = {_,_ in} {
    didSet{
      outputPipe.fileHandleForReading.readabilityHandler = { [weak self] fh in
        guard let strongSelf = self else { return }
        let data = fh.availableData
        if !data.isEmpty {
           self?.handler(data, strongSelf)
        }
      }
    }
  }
  
  var isReadingFromBuffer: Bool {
    return inputPipe.fileHandleForReading.readabilityHandler != nil
  }
  
  init(title: String, view: ConsoleView, startReading: Bool){
    self.title = title
    self.view = view
    self.innerContent = Atomic("")
    if startReading {
      startReadingFromBuffer()
    }
  }
  
  
  func write(data: Data) -> Console {
    if let str = String(data: data, encoding: .utf8){
      self.contents += str
    }
    handler(data, self)
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
      self.handler(Data(), self)
      outputPipe.fileHandleForReading.readabilityHandler = { [weak self] fh in
        guard let strongSelf = self else { return }
        let data = fh.availableData
        if !data.isEmpty {
           self?.handler(data, strongSelf)
        }
      }
      inputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
        guard let strongSelf = self else { return }
        
        let data = fileHandle.availableData
        if let string = String(data: data, encoding: .utf8) {
          strongSelf.contents += string
        }
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
