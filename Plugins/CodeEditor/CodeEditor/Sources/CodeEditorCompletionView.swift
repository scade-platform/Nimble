//
//  CodeEditorCompletionView.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 14.01.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import CodeEditor

class CodeEditorCompletionView: NSViewController {
  
  weak var textView: CodeEditorTextView? = nil
  
  private weak var currentView: NSView? = nil
  

  
  @IBOutlet weak var tableView: NSTableView!
    
  @IBOutlet weak var docView: NSView!
  
  @IBOutlet weak var emptyView: NSView!
    
    
  
  var itemsFilter: String = ""
    
  var completionItems: [CompletionItem] = []
  
  
  private(set) var isActive: Bool = false
        
  private var wasTriggered: Bool = false
  
  
  private var filterResult: [(index: Int, ranges: [Range<Int>])] = []
  
  private var completions: [CompletionItem] {
    return itemsFilter != ""
      ? filterResult.map { return completionItems[$0.index] }
      : completionItems
  }
    
  private var hasCompletions: Bool {
    return itemsFilter != ""
      ? filterResult.count > 0
      : completionItems.count > 0
  }
  
  private(set) var completionPosition = 0
  
  private var completionOrigin = CGPoint()
  
    
  private var tableScrollView: NSScrollView! {
    tableView.superview?.superview as? NSScrollView
  }
  
  private var tableViewHeightConstraint: NSLayoutConstraint! {
    return tableScrollView.constraints.first(where: { $0.identifier == .some("tableViewHeight")})
  }
    
  private var anchorPositionOffset: CGFloat {
    guard hasCompletions else {
      return emptyView.frame.size.width / 2
    }
        
    return tableView.tableColumns[0].width + (2 * tableView.intercellSpacing.width)
  }
  
  private var selection: CompletionItem? {
    guard hasCompletions else { return nil }
    return completions[tableView.selectedRow]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup(view: self.view)
    setup(view: self.emptyView)
    
    (emptyView.subviews[0].subviews[0] as? NSTextField)?.font = textView?.font
    
    tableView.backgroundColor = NSColor.clear
    docView.setBackgroundColor(NSColor.red)
    
    tableView.delegate = self
    tableView.dataSource = self
  }
      
  func handleKeyDown(with event: NSEvent) -> Bool {
    switch event.keyCode {
    // Navigate
    case Keycode.downArrow, Keycode.upArrow:
      tableView?.keyDown(with: event)
      return true
    // Select
    case Keycode.returnKey:
      insertCompletion()
      return true
    // Update
    case Keycode.delete:
      return false
    
    case _ where Keycode.chars.contains(event.keyCode):
      return false
    // Skip (but return true, to mark as processed)
    case Keycode.escape:
      close()
      return true      
    // Skip
    default:
      close()
      return false
    }
  }
    
  /// - Parameters:
  ///   - pos: UTF-16 index where the view has to appear
  ///   - triggered: 'true' if it was triggered automatically while typing  
  func open(at pos: Int, triggered: Bool) {
    guard let textView = self.textView,
          let window = textView.window else { return }
      
    
    self.isActive = true
    self.wasTriggered = triggered
        
    let screenRect = textView.firstRect(forCharacterRange: NSMakeRange(pos, 0), actualRange: nil)
    let windowRect = window.convertFromScreen(screenRect)
    
    completionPosition = pos
    completionOrigin = windowRect.origin
    
    updateViews()
  }
  
  func close() {
    currentView?.removeFromSuperview()
    isActive = false
  }
  
  func reload() {
    ///TODO: optimize filtering by e.g. filtering already filtered collection if the new filter is an extension of the old one
    filterResult = []
    let filter = itemsFilter.lowercased()
    
    var typeIcon: Bool = false
    var typeMaxChars: (count: Int, row: Int) = (0, 0)
    var labelMaxChars: (count: Int, row: Int) = (0, 0)
    
    func storeResizeData(from item: CompletionItem, at i: Int) {
      typeIcon = typeIcon || item.hasIcon
      if let type = item.detail, type.count > typeMaxChars.count {
        typeMaxChars = (type.count, i)
      }
      if item.label.count > labelMaxChars.count {
        labelMaxChars = (item.label.count, i)
      }
    }
    
    if filter != "" {
      for (index, item) in completionItems.enumerated() {
        if item.label.lowercased().starts(with: filter) {
          filterResult.append((index, [0..<filter.count]))
          storeResizeData(from: item, at: filterResult.count - 1)
        } else if !filterResult.isEmpty {
          break
        }
      }
    } else {
      completionItems.enumerated().forEach{
        storeResizeData(from: $0.element, at: $0.offset)
      }
    }
                
    if hasCompletions {
      tableView.reloadData()
      resizeToFitContent(typeMaxChars: typeMaxChars, labelMaxChars: labelMaxChars, hasTypeIcon: typeIcon)
    }
    
    if isActive {
      updateViews()
    }
  }
    
  private func setup(view: NSView) {
    view.wantsLayer = true
    view.shadow = NSShadow()
    view.layer?.shadowOpacity = 0.2
    view.layer?.shadowColor = NSColor.shadowColor.cgColor
    view.layer?.shadowOffset = NSMakeSize(0, 0)
    view.layer?.shadowRadius = 5.0
    
    let content = view.subviews[0]
    
    content.wantsLayer = true
    content.layer?.borderWidth = 1.0
    content.layer?.borderColor =  NSColor.gridColor.cgColor
    content.layer?.cornerRadius = 8.0
    content.layer?.masksToBounds = true
  }
  
  private func show(view: NSView) {
    guard let windowView = textView?.window?.contentView else { return }
    
    if currentView !== view {
      currentView?.removeFromSuperview()
      currentView = view
    }
    
    let origin = completionOrigin.offsetBy( dx: -anchorPositionOffset,
                                            dy: -currentView!.frame.size.height)
    
    currentView?.setFrameOrigin(origin)
    if currentView?.superview != windowView {
      windowView.addSubview(currentView!, positioned: .above, relativeTo: nil)
    }
  }
  
  private func updateViews() {
    if hasCompletions {
      tableView.selectRowIndexes([0], byExtendingSelection: false)
      
      tableScrollView.contentView.scroll(to: .zero)
      tableScrollView.reflectScrolledClipView(tableScrollView.contentView)
      tableScrollView.verticalScrollElasticity = .automatic
      
      show(view: self.view)
      
    } else if !wasTriggered {
      show(view: self.emptyView)
      
    } else {
      currentView?.removeFromSuperview()
      currentView = nil
    }
  }
  
  private func updateSelection() {
    ///TODO: implement
    ///
//    var viewSize = view.frame.size
//
//    if let doc = selection?.documentation {
//      print(doc)
//
//    } else if docView.frame.height > 0 {
//      viewSize.height = tableViewHeightConstraint.constant
//    }
//
//    view.setFrameSize(viewSize)
  }
  
  private func columnWidth(atColumn col: Int, row: Int) -> CGFloat {
    guard let cellView = tableView.view(atColumn: col, row: row, makeIfNecessary: true) as? NSTableCellView,
          let textSize = cellView.textField?.cell?.cellSize else { return 0.0 }
    
    return ceil(textSize.width)
  }
  
  private func resizeToFitContent(typeMaxChars: (count: Int, row: Int),
                                  labelMaxChars: (count: Int, row: Int),
                                  hasTypeIcon: Bool) {
    
    guard let tableView = self.tableView else { return }
        
    let typeColumn = tableView.tableColumns[0]
    let labelColumn = tableView.tableColumns[1]
        
    
    typeColumn.width = columnWidth(atColumn: 0, row: typeMaxChars.row) + 30.0
    labelColumn.width = columnWidth(atColumn: 1, row: labelMaxChars.row)
    

    let spacing = tableView.intercellSpacing
    
    
    // View width
    let width = typeColumn.width + labelColumn.width + (3 * spacing.width)
        
    // View height
    let numberOfRows = CGFloat(max(1, min(tableView.numberOfRows, 8)))
    let rowHeight = tableView.rowHeight + spacing.height
    let height = numberOfRows * rowHeight + spacing.height
    tableViewHeightConstraint.constant = height
            
    view.setFrameSize(NSMakeSize(width, height))
  }
    
  private func insertCompletion() {
    guard let item = selection,
          let cursor = textView?.selectedRange().location else { return }
                      
    let range = NSRange(completionPosition..<cursor)

    let text: String
    if let textEdit = item.textEdit {
      text = textEdit.newText
    } else if let newText = item.insertText {
      text = newText
    } else {
      text = item.label
    }

    textView?.insertText(text, replacementRange: range)
    close()

    let insertionRange = NSRange(location: range.location, length: text.count)
    textView?.selectSnippet(in: insertionRange)
  }
}

//MARK: - CompletionItem

fileprivate extension CompletionItem {
  var hasIcon: Bool {
//    if iconName == nil {
//      print("\(self.label) - \(self.kind)")
//    }
    return iconName != nil
  }
  
  var iconName: String? {
    switch(self.kind) {
    case .class:
      return "c.square"
    case .struct:
      return "s.square"
    case .interface:
      return "p.square"
    case .typeParameter:
      return "t.square"
    case .variable:
      return "v.square"
    case .function:
      return "fun.square"
    case .method:
      return "m.square"
    default:
      return nil
    }
  }
  
  var icon: URL? {
    guard let name = iconName else { return nil }
    return Bundle(for: CodeEditorCompletionView.self).url(forResource: "Icons/\(name)", withExtension: "svg")
  }
}


//MARK: - CompletionView

class CompletionView: NSView {
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
        
    switch Theme.Style.system {
    case .dark:
      NSColor.underPageBackgroundColor.withAlphaComponent(0.95).setFill()
    default:
      NSColor.textBackgroundColor.withAlphaComponent(0.95).setFill()
    }
    
    dirtyRect.fill()
  }
}


//MARK: - CompletionIconView

class CompletionIconView: NSTableCellView {
  @IBOutlet weak var iconView: SVGImageView! = nil
}


//MARK: - CompletionTableView

class CompletionTableView: NSTableView {
  override var acceptsFirstResponder: Bool {
    return false
  }
}

//MARK: - NSTableViewDataSource

extension CodeEditorCompletionView: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return completions.count
  }
}

//MARK: - NSTableViewDelegate

extension CodeEditorCompletionView: NSTableViewDelegate {
  private func styledLabel(_ label: String, for row: Int) -> NSAttributedString {
    let label = NSMutableAttributedString(string: label)
    
    let color = NSColor.yellow
    let underlineStyle = NSNumber(value: NSUnderlineStyle.single.rawValue)
            
    filterResult[row].ranges.forEach {
      label.addAttribute(.backgroundColor, value: color.withAlphaComponent(0.3), range: NSRange($0))
      label.addAttribute(.underlineColor, value: color, range: NSRange($0))
      label.addAttribute(.underlineStyle, value: underlineStyle, range: NSRange($0))
    }
    
    return label
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let item = completions[row]
    var cell: NSTableCellView? = nil

    if tableColumn == tableView.tableColumns[0], item.hasIcon ||  item.detail != nil {
      let typeCell = tableView.makeCell(id: "TypeCell") as? CompletionIconView
      
      cell = typeCell
      cell?.textField?.stringValue = item.detail ?? ""
      cell?.textField?.textColor = NSColor.systemGray
      
      typeCell?.iconView.url = item.icon
      
    } else if tableColumn == tableView.tableColumns[1] {
      cell = tableView.makeCell(id: "LabelCell")
            
      if filterResult.count > 0 {
        cell?.textField?.attributedStringValue = styledLabel(item.label, for: row)
      } else {
        cell?.textField?.stringValue = item.label
      }
    }    
    
    cell?.identifier = nil
    cell?.textField?.font = textView?.font
    cell?.textField?.isEnabled = false
    
    return cell
  }
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    guard tableView.selectedRow >= 0,
          let row = tableView?.rowView(atRow: tableView.selectedRow, makeIfNecessary: true) else { return }
    
    row.isEmphasized = true
    updateSelection()
  }
    
  func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    return completions.count > 0
  }
}
