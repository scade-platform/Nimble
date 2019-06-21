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
    
    //subscribe to type text changes
    NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSText.didChangeNotification, object: textView)
    
    setupTextView(textView: textView)
    loadContent()
    }
    
  private func loadContent() {
    guard let textView = textView,
        let layoutManager = textView.layoutManager,
        let doc = doc else {
        return
    }
   
    //update textStorage of textView.layoutManager
    layoutManager.replaceTextStorage(doc.textStorage)

    //setup line count
    textView.setUpLineNumberView()
    
    //setup text color & font from Theme
    if let textStorage = textView.textStorage, let theme = ThemeManager.shared.theme  {
        for layoutManager in textStorage.layoutManagers {
            layoutManager.firstTextView?.font = theme.font
            layoutManager.firstTextView?.textColor = theme.text.color
        }
    }
    
    //highlight syntax
      _ = doc.syntaxParser.highlightAll()
    }

 
    func setupTextView(textView: NSTextView) {
        if let theme = ThemeManager.shared.theme {
            textView.applyTheme(theme: theme)
        }


        // setup layoutManager and textContainer
        let textContainer = TextContainer()
     //   textContainer.isHangingIndentEnabled = defaults[.enablesHangingIndent]
     //   textContainer.hangingIndentWidth = defaults[.hangingIndentWidth]
        textView.replaceTextContainer(textContainer)
        
        let layoutManager = LayoutManager()
        
        // set font
      //  layoutManager.textFont = font
        
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
        
     
       // layoutManager.usesAntialias = defaults[.shouldAntialias]
    }
    
    @objc private func textDidChange(notification: NSNotification) {
        _ = doc?.syntaxParser.highlightAll()
    }
 }
