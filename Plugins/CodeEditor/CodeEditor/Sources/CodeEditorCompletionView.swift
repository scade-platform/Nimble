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
  
  @IBOutlet weak var tableView: NSTableView?
    
  @IBOutlet weak var docView: NSView?
  
  var itemsFilter: String = ""
  
  var completionItems: [CompletionItem] = []
  
  
  private var completions: [CompletionItem] = []
    
  private(set) var completionPosition = 0
  
  private var completionOrigin = CGPoint()
      
  
  var isPresented: Bool {
    return view.superview != nil
  }
  
  private var backgroundColor: NSColor {
    NSColor.underPageBackgroundColor //withAlphaComponent(0.95)
  }
  
  private var tableScrollView: NSScrollView? {
    tableView?.superview?.superview as? NSScrollView
  }
  
  private var tableViewHeightConstraint: NSLayoutConstraint? {
    return tableScrollView?.constraints.first(where: { $0.identifier == .some("tableViewHeight")})
  }
    
  private var anchorPositionOffset: CGFloat {
    guard let columns = tableView?.tableColumns,
          let spacing = tableView?.intercellSpacing.width,
          columns.count > 0 else { return 0.0 }
          
    return columns[0..<columns.count-1].reduce(spacing) {$0 + $1.width + spacing}
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView?.makeRounded()
    tableScrollView?.makeRounded()
    
    view.setBackgroundColor(backgroundColor)
    tableView?.backgroundColor = NSColor.clear
    
    docView?.setBackgroundColor(NSColor.red)
    
    tableView?.delegate = self
    tableView?.dataSource = self
  }
  
  override func updateViewConstraints() {
    resizeToFitContent()
    super.updateViewConstraints()
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
      hide()
      return true
    // Update
    case Keycode.delete:
      return false
    
    case _ where Keycode.chars.contains(event.keyCode):
      return false
    // Skip (but return true, to mark as processed)
    case Keycode.escape:
      hide()
      return true      
    // Skip
    default:
      hide()
      return false
    }
  }
  
  func show(at pos: Int) {
    guard let textView = self.textView,
          let window = textView.window else { return }
            
    let screenRect = textView.firstRect(forCharacterRange: NSMakeRange(pos, 0), actualRange: nil)
    let windowRect = window.convertFromScreen(screenRect)
    
    completionPosition = pos
    completionOrigin = windowRect.origin
    
    updateViews()
        
    if(!isPresented) {
      window.contentViewController?.addChild(self)
      window.contentView?.addSubview(view, positioned: .above, relativeTo: nil)
    }
  }
    
  func hide() {
    removeFromParent()
    view.removeFromSuperview()
  }
    
  func reload() {
    ///TODO: optimize filtering by e.g. filtering already filtered collection if the new filter is an extension of the old one
    completions = completionItems.filter {
      $0.label.starts(with: itemsFilter)
    }
    
    tableView?.reloadData()
    updateViews()
  }
  
  
  private func insertCompletion() {
    guard completions.count > 0,
          let row = tableView?.selectedRow,
          let cursor = textView?.selectedRange().location else { return }
    
          
    let item = completions[row]
    let range = NSRange(completionPosition..<cursor)
    
    if let textEdit = item.textEdit {
      textView?.insertText(textEdit.newText, replacementRange: range)
      
    } else if let newText = item.insertText {
      textView?.insertText(newText, replacementRange: range)
    
    } else {
      textView?.insertText(item.label, replacementRange: range)
    }
  }
  
  private func updateViews() {
    if completions.count == 0 {
      tableView?.intercellSpacing = NSMakeSize(5.0, 2.0)
      tableView?.selectRowIndexes([], byExtendingSelection: false)
      
      tableScrollView?.verticalScrollElasticity = .none
      
    } else {
      tableView?.intercellSpacing = NSMakeSize(3.0, 2.0)
      tableView?.selectRowIndexes([0], byExtendingSelection: false)
      
      if let scrollView = tableScrollView {
        scrollView.contentView.scroll(to: .zero)
        scrollView.reflectScrolledClipView(scrollView.contentView)
        scrollView.verticalScrollElasticity = .automatic
      }
    }
    
    updateViewConstraints()
    
    let origin = completionOrigin.offsetBy(dx: -anchorPositionOffset,
                                           dy: -view.frame.size.height)
    view.setFrameOrigin(origin)
  }
  
  private func resizeToFitContent() {
    guard let tableView = self.tableView else { return }
        
    var columnsWidth = [CGFloat](repeating: 0.0, count: tableView.numberOfColumns)
    
    for row in 0..<tableView.numberOfRows {
      for col in 0..<tableView.numberOfColumns {
        guard let view = tableView.view(atColumn: col, row: row, makeIfNecessary: true) as? NSTableCellView,
              let cellSize = view.textField?.cell?.cellSize else { continue }
        let maxWidth = tableView.tableColumns[col].maxWidth
        columnsWidth[col] = min(maxWidth, max(columnsWidth[col], cellSize.width))
      }
    }
    
    
    let spacing = tableView.intercellSpacing
    
    // Setup width
    var width = spacing.width * CGFloat(columnsWidth.count + 1)
    for (i, column) in tableView.tableColumns.enumerated() {
      column.width = ceil(columnsWidth[i])
      width += column.width
    }
    
    // Setup height
    let numberOfRows = CGFloat(max(1, min(tableView.numberOfRows, 8)))
    let rowHeight = tableView.rowHeight + spacing.height
    let height = numberOfRows * rowHeight + spacing.height
    tableViewHeightConstraint?.constant = height
            
    view.setFrameSize(NSMakeSize(width, height))
  }
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
    // Return a dummy row presenting "No completions"
    return completions.count > 0 ? completions.count : 1
  }
}

//MARK: - NSTableViewDelegate

extension CodeEditorCompletionView: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    var cell: NSTableCellView? = nil
    
    let completion = completions.count > 0 ? completions[row] : nil
        
    if tableColumn == tableView.tableColumns[0], let detail = completion?.detail {
      cell = tableView.makeTypeCell()
      cell?.textField?.stringValue = detail
      
    } else if tableColumn == tableView.tableColumns[1] {
      cell = tableView.makeLabelCell()
      cell?.textField?.stringValue = completion?.label ?? "No completions"
    }
    
    ///FIX: turn-on reuse of cells
    cell?.identifier = nil
    cell?.textField?.font = textView?.font
    cell?.textField?.isEnabled = false
    
    return cell
  }
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    guard let sel = tableView?.selectedRow, sel >= 0,
          let row = tableView?.rowView(atRow: sel, makeIfNecessary: true) else { return }
    
    row.isEmphasized = true
  }
    
  func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    return completions.count > 0
  }
}

fileprivate extension NSTableView {
  func makeTypeCell() -> NSTableCellView? {
    return makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TypeCell"), owner: nil) as? NSTableCellView
  }
  
  func makeLabelCell() -> NSTableCellView? {
    return makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "LabelCell"), owner: nil) as? NSTableCellView
  }
}

fileprivate extension NSView {
  func makeRounded(_ cornerRadius: CGFloat = 8.0) {
    self.wantsLayer = true
    self.layer?.cornerRadius = cornerRadius
    self.layer?.masksToBounds = true
  }
}
