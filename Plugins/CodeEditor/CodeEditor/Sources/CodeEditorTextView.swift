//
//  CodeEditorTextView.swift
//  CodeEditor
//
//  Created by Mark Goldin on 25/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

private let kTextContainerInset = NSSize(width: 0.0, height: 4.0)

// MARK: -

final class CodeEditorTextView: NSTextView {
    
    
    // MARK: -
    // MARK: Lifecycle
    
    required init?(coder: NSCoder) {

        // set paragraph style values
        
        if let theme = ThemeManager.shared.theme {
            lineHeight = theme.lineHeight
            tabWidth = theme.tabWidth
        } else {
            lineHeight = 1.2
            tabWidth = 4
        }

        super.init(coder: coder)
        
        // workaround for: the text selection highlight can remain between lines (2017-09 macOS 10.13).
        self.scaleUnitSquare(to: NSSize(width: 0.5, height: 0.5))
        self.scaleUnitSquare(to: self.convert(.unit, from: nil))  // reset scale
        
        // setup layoutManager and textContainer
        let textContainer = TextContainer()
        textContainer.isHangingIndentEnabled = true //defaults[.enablesHangingIndent]
        textContainer.hangingIndentWidth = 0 //defaults[.hangingIndentWidth]
        self.replaceTextContainer(textContainer)
        
        let layoutManager = LayoutManager()
        self.textContainer!.replaceLayoutManager(layoutManager)
        self.layoutManager?.allowsNonContiguousLayout = true
        
        // set layout values (wraps lines)
        self.minSize = self.frame.size
        self.maxSize = .infinite
        self.isHorizontallyResizable = false
        self.isVerticallyResizable = true
        self.autoresizingMask = .width
        self.textContainerInset = kTextContainerInset
        
        // set NSTextView behaviors
        self.baseWritingDirection = .leftToRight  // default is fixed in LTR
        self.allowsDocumentBackgroundColorChange = false
        self.allowsUndo = true
        self.isRichText = false
        self.importsGraphics = false
        self.usesFindPanel = true
        self.acceptsGlyphInfo = true
        self.linkTextAttributes = [.cursor: NSCursor.pointingHand,
                                   .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        self.invalidateDefaultParagraphStyle()
    }

    /// append inset only to the bottom for overscroll
    override var textContainerOrigin: NSPoint {
        
        return NSPoint(x: super.textContainerOrigin.x, y: kTextContainerInset.height)
    }

    
    /// text font
    override var font: NSFont? {
        
        get {
            // make sure to return by user defined font
            return (self.layoutManager as? LayoutManager)?.textFont ?? super.font
        }
        
        set {
            guard let font = newValue else { return }
            
            // let LayoutManager have the font too to avoid the issue where the line height can be inconsistance by a composite font
            // -> Because `textView.font` can return a Japanese font
            //    when the font is for one-bites and the first character of the content is Japanese one,
            //    LayoutManager should not use `textView.font`.
            (self.layoutManager as? LayoutManager)?.textFont = font
            
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
        if let lineHeight = (self.layoutManager as? LayoutManager)?.lineHeight {
            self.enclosingScrollView?.lineScroll = lineHeight
        }
        
        // apply new style to current text
        self.invalidateStyle()
    }
    
}

