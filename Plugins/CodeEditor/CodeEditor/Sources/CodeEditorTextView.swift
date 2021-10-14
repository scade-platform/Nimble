//
//  CodeEditorTextView.swift
//  CodeEditor
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa

// MARK: -

final class CodeEditorTextView: NSTextView {

  // MARK: - CodeEditorView

  var editorView: CodeEditorView? {
    self.delegate as? CodeEditorView
  }

  var lineHighLightColor: NSColor? = nil
    
  // MARK: - Line numbers

  var lineNumberView: LineNumberView? = nil

  // MARK: - Snippets

  var snippetViews: [NSView] = []

  required init?(coder: NSCoder) {

    lineHeight = 1.0
    tabWidth = 4
    super.init(coder: coder)
    
    self.drawsBackground = true
    
    // workaround for: the text selection highlight can remain between lines (2017-09 macOS 10.13).
    self.scaleUnitSquare(to: NSSize(width: 0.5, height: 0.5))
    self.scaleUnitSquare(to: self.convert(CGSize(width: 1, height: 1), from: nil))  // reset scale

    let layoutManager = CodeEditorLayoutManager()
    layoutManager.delegate = self

    self.textContainer!.lineFragmentPadding = 0.0
    self.textContainer!.replaceLayoutManager(layoutManager)
    //TODO: add lazy layout for DiagnosticView to use this flag to improve perfomance
//    self.layoutManager!.allowsNonContiguousLayout = true

    // set layout values (wraps lines)
    self.minSize = self.frame.size
    self.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
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
    // Disable auto replacement of ... to one special glyph
    self.isAutomaticDashSubstitutionEnabled = false
    
    self.invalidateDefaultParagraphStyle()
    
    //TODO: make it optional, if no wrapping enabled, turn on horizontal scrolling
//    self.wrapsLines = true
    
    //TODO: compute it as an overscroll ration relative to the self.frame
    self.textContainerInset.height = 100.0
  }
  
  public override func keyDown(with event: NSEvent) {
    if let specialKey = event.specialKey {
      switch specialKey {
      case .tab:
        if selectClosestSnippet() {
          return
        }        
      default:
        break
      }
    }

    guard editorView?.handleKeyDown(with: event) ?? false else {
      super.keyDown(with: event)
      return
    }
  }
  
  public override func mouseDown(with event: NSEvent) {
    guard editorView?.handleMouseDown(with: event) ?? false else {
      super.mouseDown(with: event)
      return
    }
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(textDidChange),
                                           name: NSText.didChangeNotification, object: self)
  }
  
  
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
    didSet {
      self.invalidateDefaultParagraphStyle()
      (self.delegate as? CodeEditorTextViewDelegate)?.fontDidChange()
    }
  }
  
  /// scroll to display specific range
  override func scrollRangeToVisible(_ range: NSRange) {
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
    
    let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineHeightMultiple = self.lineHeight
    
    
    // calculate tab interval
    if let font = self.font {
      let spaceWidth = " ".size(withAttributes: [NSAttributedString.Key.font: font]).width
      paragraphStyle.tabStops = []
      paragraphStyle.defaultTabInterval = CGFloat(self.tabWidth) * spaceWidth
    }
    
    paragraphStyle.baseWritingDirection = self.baseWritingDirection
    
    self.defaultParagraphStyle = paragraphStyle


    self.typingAttributes[.paragraphStyle] = paragraphStyle
    
    // tell line height also to scroll view so that scroll view can scroll line by line
    if let lineHeight = (self.layoutManager as? CodeEditorLayoutManager)?.lineHeight {
      self.enclosingScrollView?.lineScroll = lineHeight
    }
    
    // apply new style to current text
    self.invalidateStyle()
  }


  override func drawBackground(in rect: NSRect) {
    super.drawBackground(in: rect)
    self.highlightCurrentLine(in: rect)
  }
  
  //TODD: remove hightliting for line with selected text
  private func highlightCurrentLine(in rect: NSRect) {
    guard let stringRange = Range(self.selectedRange(), in: self.string) else {
      return
    }
    let lineRange = self.string.lineRange(for: stringRange)
    let lineRect = highlightRect(for: lineRange)
    guard let color = lineHighLightColor else {
      return
    }
    color.withAlphaComponent(0.3).set()
    NSBezierPath.fill(lineRect)
  }
  
  // Returns a rectangle suitable for highlighting a background rectangle for the given text range.
  private func highlightRect(for range: Range<String.Index>) -> NSRect {
    let boundingRect = self.boundingRect(for: range)!
    let y = boundingRect.origin.y
    let w = self.bounds.size.width
    let h = boundingRect.size.height
    return NSMakeRect(0, y, w, h)
  }


  override func setSelectedRanges(_ ranges: [NSValue],
                                  affinity: NSSelectionAffinity,
                                  stillSelecting stillSelectingFlag: Bool) {

    super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelectingFlag)

    self.lineNumberView?.needsDisplay = true
  }

}


// MARK: - CodeEditorTextViewDelegate

protocol CodeEditorTextViewDelegate {
  func fontDidChange() -> Void
}


extension CodeEditorTextViewDelegate {
  func fontDidChange() -> Void {}
}



// MARK: - NSLayoutManagerDelegate

extension CodeEditorTextView: NSLayoutManagerDelegate {
  func layoutManager(_ layoutManager: NSLayoutManager,
                     shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>,
                     properties: UnsafePointer<NSLayoutManager.GlyphProperty>,
                     characterIndexes: UnsafePointer<Int>,
                     font: NSFont,
                     forGlyphRange range: NSRange) -> Int {

    var chunckIndex = 0
    var chunckLocation = range.lowerBound

    textStorage?.enumerateSnippets(in: range) {
      let chunckLength = $0.range.upperBound - chunckLocation
      let chunckSnippetIndex = $0.range.lowerBound - range.lowerBound

      var chunckGlyphs = [CGGlyph](repeating: kCGFontIndexInvalid, count:  chunckLength)
      var chunckProperties = [NSLayoutManager.GlyphProperty](repeating: .null , count: chunckLength)

      // Copy non-snippet glyphs
      for i in chunckIndex..<chunckSnippetIndex {
        chunckGlyphs[i - chunckIndex] = glyphs[i]
        chunckProperties[i - chunckIndex] = properties[i]
      }

      // Set first snippet glyph as a control charackter
      chunckProperties[chunckSnippetIndex - chunckIndex] = .controlCharacter

      layoutManager.setGlyphs(chunckGlyphs,
                              properties: chunckProperties,
                              characterIndexes: characterIndexes.advanced(by: chunckIndex),
                              font: font, forGlyphRange: NSRange(location: chunckLocation, length: chunckLength))

      chunckIndex = chunckSnippetIndex + $0.range.length
      chunckLocation = $0.range.upperBound
    }

    // Copy rest non-snippet glyphs
    if chunckIndex > 0 && chunckIndex < range.length {
      layoutManager.setGlyphs(glyphs.advanced(by: chunckIndex),
                              properties: properties.advanced(by: chunckIndex),
                              characterIndexes: characterIndexes.advanced(by: chunckIndex),
                              font: font, forGlyphRange: NSRange(location: chunckLocation, length: range.length - chunckIndex))

      chunckIndex = range.length
    }

    return chunckIndex
  }


  func layoutManager(_ layoutManager: NSLayoutManager,
                     shouldUse action: NSLayoutManager.ControlCharacterAction,
                     forControlCharacterAt charIndex: Int) -> NSLayoutManager.ControlCharacterAction {

    if let _ = textStorage?.attribute(.snippet, at: charIndex, effectiveRange: nil) {
      return .whitespace
    }

    return action
  }

  func layoutManager(_ layoutManager: NSLayoutManager,
                     boundingBoxForControlGlyphAt glyphIndex: Int,
                     for textContainer: NSTextContainer,
                     proposedLineFragment proposedRect: NSRect,
                     glyphPosition: NSPoint,
                     characterIndex charIndex: Int) -> NSRect {

    var glyphSize = NSSize(width: 0.0, height: proposedRect.height)
    if let snippet = textStorage?.attribute(.snippet, at: charIndex, effectiveRange: nil) as? NSView {
      glyphSize = snippet.frame.size
    }
    return NSRect(origin: glyphPosition, size: glyphSize)
  }
}


