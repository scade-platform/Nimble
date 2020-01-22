//
//  CodeEditorTextView.swift
//  CodeEditor
//
//  Created by Mark Goldin on 25/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

// MARK: -

final class CodeEditorTextView: NSTextView, CurrentLineHighlighting {
  
  // MARK: -
  // MARK: CurrentLineHighlighting
  
  var needsUpdateLineHighlight = true
  var lineHighLightRects: [NSRect] = []
  var lineHighLightColor: NSColor? = nil
    
  // MARK: -
  
  var lineNumberView: LineNumberView? = nil
  
  // MARK: -
  // MARK: Lifecycle
  
  required init?(coder: NSCoder) {
    
    // set paragraph style values

//    if let theme = ThemeManager.shared.theme {
//      lineHeight = theme.lineHeight
//      tabWidth = theme.tabWidth
//    } else {
    lineHeight = 1.2
    tabWidth = 4
//    }
    super.init(coder: coder)
    
    self.drawsBackground = true
    
    // workaround for: the text selection highlight can remain between lines (2017-09 macOS 10.13).
    self.scaleUnitSquare(to: NSSize(width: 0.5, height: 0.5))
    self.scaleUnitSquare(to: self.convert(.unit, from: nil))  // reset scale
    
    // setup layoutManager and textContainer
    let textContainer = TextContainer()
    // TODO: move to settings
    textContainer.isHangingIndentEnabled = true //defaults[.enablesHangingIndent]
    textContainer.hangingIndentWidth = 2 //defaults[.hangingIndentWidth]
    self.replaceTextContainer(textContainer)
    
    //let layoutManager = LayoutManager()
    let layoutManager = CodeEditorLayoutManager()
    self.textContainer!.replaceLayoutManager(layoutManager)
    self.layoutManager!.allowsNonContiguousLayout = true
    
    // set layout values (wraps lines)
    self.minSize = self.frame.size
    self.maxSize = .infinite
    self.isHorizontallyResizable = false
    self.isVerticallyResizable = true
    self.autoresizingMask = .width
    
    // set NSTextView behaviors
    self.baseWritingDirection = .leftToRight  // default is fixed in LTR
    self.allowsDocumentBackgroundColorChange = false
    self.allowsUndo = true
    self.isRichText = false
    self.importsGraphics = false
    self.usesFindPanel = true
    self.acceptsGlyphInfo = true
    
    //TODO: setup by applying themes
    self.linkTextAttributes = [.cursor: NSCursor.pointingHand,
                               .underlineStyle: NSUnderlineStyle.single.rawValue]    

    self.isAutomaticQuoteSubstitutionEnabled = false
    
    self.invalidateDefaultParagraphStyle()
    
    //TODO: make it optional, if no wrapping enabled, turn on horizontal scrolling
    self.wrapsLines = true
    
    //TODO: compute it as an overscroll ration relative to the self.frame
    self.textContainerInset.height = 100.0
  }
  
  
  public override func awakeFromNib() {
    if let scrollView = self.enclosingScrollView {
      self.lineNumberView = LineNumberView(textView: self)
      
      scrollView.verticalRulerView = lineNumberView
      scrollView.hasVerticalRuler = true
      scrollView.rulersVisible = true
    }
    
    self.postsFrameChangedNotifications = true
    NotificationCenter.default.addObserver(self, selector: #selector(frameDidChange),
                                           name: NSView.frameDidChangeNotification, object: self)
    
    NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSText.didChangeNotification, object: self)
  }
  
//  override var wantsUpdateLayer: Bool { return true }
//
//  override func updateLayer() {
//      layer?.backgroundColor = backgroundColor.cgColor
//  }
  
  @objc private func frameDidChange(notification: NSNotification) {
    self.lineNumberView?.needsDisplay = true
  }
  
  @objc private func textDidChange(notification: NSNotification) {
    self.lineNumberView?.needsDisplay = true
  }
  
  
  // append inset only to the bottom for overscroll
  override var textContainerOrigin: NSPoint {
    return NSPoint(x: super.textContainerOrigin.x, y: 0.0)
  }
  
  
  /// text font
  override var font: NSFont? {
    get {
      return (self.layoutManager as? CodeEditorLayoutManager)?.textFont ?? super.font
    }
    
    set {
      guard let font = newValue else { return }
      
      (self.layoutManager as? CodeEditorLayoutManager)?.textFont = font
      
      super.font = font
      self.invalidateDefaultParagraphStyle()
    }
  }
  
  /// scroll to display specific range
  override func scrollRangeToVisible(_ range: NSRange) {
    
    // scroll line by line if an arrow key is pressed
    // -> Perform only when the scroll target is near by the visible area.
    //    Otherwise with the noncontiguous layout:
    //    - Scroll jumps when the cursor is initially in the end part of document.
    //    - Scroll doesn't reach to the bottom with command+down arrow.
    //    (2018-12 macOS 10.14)
    if NSEvent.modifierFlags.contains(.numericPad),
      let rect = self.boundingRect(for: range),
      let lineHeight = self.enclosingScrollView?.lineScroll,
      self.visibleRect.insetBy(dx: -lineHeight, dy: -lineHeight).intersects(rect)
    {
      super.scrollToVisible(rect)  // move minimum distance
      return
    }
    
    super.scrollRangeToVisible(range)
  }
  
  
  /// change text layout orientation
  override func setLayoutOrientation(_ orientation: NSLayoutManager.TextLayoutOrientation) {
    
    // -> need to send KVO notification manually on Swift (2016-09-12 on macOS 10.12 SDK)
    self.willChangeValue(forKey: #keyPath(layoutOrientation))
    super.setLayoutOrientation(orientation)
    self.didChangeValue(forKey: #keyPath(layoutOrientation))
    
    //  self.invalidateNonContiguousLayout()
    
    // reset writing direction
    if orientation == .vertical {
      self.baseWritingDirection = .leftToRight
    }
    
    // reset text wrapping width
    if self.wrapsLines {
      let keyPath = (orientation == .vertical) ? \NSSize.height : \NSSize.width
      self.frame.size[keyPath: keyPath] = self.visibleRect.width * self.scale
    }
  }
  
  // MARK: Public Accessors
  
  /// tab width in number of spaces
  @objc var tabWidth: Int {
    
    didSet {
      if tabWidth <= 0 {
        tabWidth = oldValue
      }
      guard tabWidth != oldValue else { return }
      
      // apply to view
      self.invalidateDefaultParagraphStyle()
    }
  }
  
  /// line height multiple
  var lineHeight: CGFloat {
    
    didSet {
      if lineHeight <= 0 {
        lineHeight = oldValue
      }
      guard lineHeight != oldValue else { return }
      
      // apply to view
      self.invalidateDefaultParagraphStyle()
    }
  }
  
  // MARK: Public Methods
  
  /// invalidate string attributes
  func invalidateStyle() {
    
    assert(Thread.isMainThread)
    
    guard let textStorage = self.textStorage else { return assertionFailure() }
    guard textStorage.length > 0 else { return }
    
    textStorage.addAttributes(self.typingAttributes, range: textStorage.range)
  }
  
  /// set defaultParagraphStyle based on font, tab width, and line height
  private func invalidateDefaultParagraphStyle() {
    
    assert(Thread.isMainThread)
    
    let paragraphStyle = NSParagraphStyle.default.mutable
    
    // set line height
    //   -> The actual line height will be calculated in LayoutManager and ATSTypesetter based on this line height multiple.
    //      Because the default Cocoa Text System calculate line height differently
    //      if the first character of the document is drawn with another font (typically by a composite font).
    //   -> Round line height for workaround to avoid expanding current line highlight when line height is 1.0. (2016-09 on macOS Sierra 10.12)
    //      e.g. Times
    paragraphStyle.lineHeightMultiple = self.lineHeight.rounded(to: 5)
    
    // calculate tab interval
    if let font = self.font {
      paragraphStyle.tabStops = []
      paragraphStyle.defaultTabInterval = CGFloat(self.tabWidth) * font.spaceWidth
    }
    
    paragraphStyle.baseWritingDirection = self.baseWritingDirection
    
    self.defaultParagraphStyle = paragraphStyle
    
    // add paragraph style also to the typing attributes
    //   -> textColor and font are added automatically.
    self.typingAttributes[.paragraphStyle] = paragraphStyle
    
    // tell line height also to scroll view so that scroll view can scroll line by line
    if let lineHeight = (self.layoutManager as? CodeEditorLayoutManager)?.lineHeight {
      self.enclosingScrollView?.lineScroll = lineHeight
    }
    
    // apply new style to current text
    self.invalidateStyle()
  }
  
  
  /// draw background
  override func drawBackground(in rect: NSRect) {
    
    super.drawBackground(in: rect)
    
    // draw current line highlight
    if true { //UserDefaults.standard[.highlightCurrentLine] {
      self.drawCurrentLine(in: rect)
    }
    
    //self.drawRoundedBackground(in: rect)
  }
  
  override func setSelectedRanges(_ ranges: [NSValue], affinity: NSSelectionAffinity, stillSelecting stillSelectingFlag: Bool) {
    super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelectingFlag)
    
    self.needsUpdateLineHighlight = true
    self.lineNumberView?.needsDisplay = true
  }
  
  
  // MARK: Auto-closing + auto-indents
  
  
  let autoClosingPairs = ["()", "[]", "{}"]

  var selectedIndex: String.Index {
    string.index(at: selectedRange().location)
  }
  
  var currentLine: String {
    return String(string[string.lineRange(at: selectedIndex)])
  }
  
  var currentIndent: String {
    let currentLine = self.currentLine
    guard let regexp = try? NSRegularExpression(pattern: "^(\\t|\\s)+"),
          let result = regexp.firstMatch(in: currentLine,
                                         range: NSRange(0..<currentLine.count)) else { return "" }
      
    return String(currentLine[result.range.lowerBound..<result.range.upperBound])
  }
  
  func surroundRange(_ index: String.Index) -> Range<String.Index> {
    let lineRange = string.lineRange(at: selectedIndex)
    let from = (index > lineRange.lowerBound) ? string.index(before: index) : lineRange.lowerBound
    let to = (index < lineRange.upperBound) ? string.index(after: index) : lineRange.upperBound
    return from..<to
  }
  
  func surroundString(_ index: String.Index) -> String {
    return String(string[surroundRange(index)])
  }
  
  func stringWidth(for string: String) -> CGFloat? {
    let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
    let atrStr = NSAttributedString(string: string, attributes: [NSAttributedString.Key.font : font])
    let tabsCount = string.filter{$0 == "\t"}.count
    return atrStr.size().width + CGFloat((self.tabWidth * tabsCount)) + 20
  }
    
  
  override func insertText(_ string: Any, replacementRange: NSRange) {
    super.insertText(string, replacementRange: replacementRange)
    guard let input = string as? String else { return }
    
    switch input {
    case "(":
      super.insertText(")", replacementRange: replacementRange)
      super.moveBackward(self)
      
    case "[":
      super.insertText("]", replacementRange: replacementRange)
      super.moveBackward(self)
      
    case "{":
      super.insertText("}", replacementRange: replacementRange)
      super.moveBackward(self)
      
    default:
      break
    }
  }
  
  override func insertNewline(_ sender: Any?) {
    let currentIndent = self.currentIndent
    let autoIndentLine = autoClosingPairs.contains(surroundString(selectedIndex))
    
    super.insertNewline(sender)
    super.insertText(currentIndent, replacementRange: selectedRange())

    if autoIndentLine {
      super.insertTab(sender)
      super.insertNewline(sender)
      super.insertText(currentIndent, replacementRange: selectedRange())
      
      super.moveToLeftEndOfLine(sender)
      super.moveBackward(sender)
    }
  }
  
  override func deleteBackward(_ sender: Any?) {
    if autoClosingPairs.contains(surroundString(selectedIndex)) {
      super.deleteForward(sender)
      super.deleteBackward(sender)
    } else {
      super.deleteBackward(sender)
    }
  }
  
}

