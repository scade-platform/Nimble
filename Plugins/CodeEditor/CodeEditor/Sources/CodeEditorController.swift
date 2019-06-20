//
//  CodeEditorController.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

class CodeEditorController: NSViewController, NSTextViewDelegate {
  weak var doc: SourceCodeDocument? = nil {
    didSet {
      loadContent()
    }
  }
  
  @IBOutlet
  weak var textView: NSTextView? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let textView = textView else {
        return
    }
    
    setupTextView(textView: textView)
    loadContent()
    }
  
  private func loadContent() {
    guard let textView = textView,
        let layoutManager = textView.layoutManager,
        let doc = doc else {
        return
    }

        doc.syntaxParser.textStorage.addLayoutManager(layoutManager)
       _ = doc.syntaxParser.highlightAll()
        textView.setUpLineNumberView()
    }

 
    func setupTextView(textView: NSTextView) {
        if let theme = ThemeManager.shared.theme {
            textView.applyTheme(theme: theme)
        }
        
        let font = NSFont.init(name: "SFMono-Medium", size: 12.0) ?? NSFont.systemFont(ofSize: 12.0)
        textView.font = font
        textView.setUpLineNumberView()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.0
        textView.defaultParagraphStyle = paragraphStyle
        
        // setup layoutManager and textContainer
        let textContainer = TextContainer()
     //   textContainer.isHangingIndentEnabled = defaults[.enablesHangingIndent]
     //   textContainer.hangingIndentWidth = defaults[.hangingIndentWidth]
        textView.replaceTextContainer(textContainer)
        
        let layoutManager = LayoutManager()
        textView.textContainer!.replaceLayoutManager(layoutManager)
        textView.layoutManager?.allowsNonContiguousLayout = true
        
        // set layout values (wraps lines)
//        self.minSize = self.frame.size
//        self.maxSize = .infinite
//        self.isHorizontallyResizable = false
//        self.isVerticallyResizable = true
//        self.autoresizingMask = .width
//        self.textContainerInset = kTextContainerInset
        
        // set NSTextView behaviors
//        self.baseWritingDirection = .leftToRight  // default is fixed in LTR
//        self.allowsDocumentBackgroundColorChange = false
//        self.allowsUndo = true
//        self.isRichText = false
//        self.importsGraphics = false
//        self.usesFindPanel = true
//        self.acceptsGlyphInfo = true
//        self.linkTextAttributes = [.cursor: NSCursor.pointingHand,
//                                   .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        // setup behaviors
//        self.smartInsertDeleteEnabled = defaults[.smartInsertAndDelete]
//        self.isAutomaticQuoteSubstitutionEnabled = defaults[.enableSmartQuotes]
//        self.isAutomaticDashSubstitutionEnabled = defaults[.enableSmartDashes]
//        self.isAutomaticLinkDetectionEnabled = defaults[.autoLinkDetection]
//        self.isContinuousSpellCheckingEnabled = defaults[.checkSpellingAsType]
        
        // set font
        layoutManager.textFont = font
       // layoutManager.usesAntialias = defaults[.shouldAntialias]
    }
 }
