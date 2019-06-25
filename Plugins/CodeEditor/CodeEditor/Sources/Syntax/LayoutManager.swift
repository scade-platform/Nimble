//
//  LayoutManager.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//
//

import Cocoa
import CoreText

final class LayoutManager: NSLayoutManager, ValidationIgnorable {
    
    // MARK: Public Properties
    
    var ignoresDisplayValidation = false
    
    var showsInvisibles = false {
        
        didSet {
            guard let textStorage = textStorage else {
                return assertionFailure()
            }
            
            let wholeRange = textStorage.range
            
            if showsOtherInvisibles {
                // -> force recaluculate layout in order to make spaces for control characters drawing
                invalidateGlyphs(forCharacterRange: wholeRange, changeInLength: 0, actualCharacterRange: nil)
                invalidateLayout(forCharacterRange: wholeRange, actualCharacterRange: nil)
            } else {
                invalidateDisplay(forCharacterRange: wholeRange)
            }
        }
    }
    
    var usesAntialias = true
    
    var textFont: NSFont? {
        
        // keep body text font to avoid the issue where the line height can be different by composite font
        // -> DO NOT use `self.firstTextView.font`, because it may return another font in case for example:
        //    Japansete text is input nevertheless the font that user specified dosen't support it.
        didSet {
            // cache metric values to fix line height
            if let textFont = textFont {
                defaultLineHeight = defaultLineHeight(for: textFont)
                defaultBaselineOffset = defaultBaselineOffset(for: textFont)
                
                // cache width of space char for hanging indent width calculation
                spaceWidth = textFont.spaceWidth
                
//                // cache replacement glyph width for ATS Typesetter
//                let invisibleFont = NSFont(named: .lucidaGrande, size: textFont.pointSize) ?? textFont  // use current text font for fallback
//                let replacementGlyph = invisibleFont.glyph(withName: "replacement")  // U+FFFD
//                self.replacementGlyphWidth = invisibleFont.boundingRect(forGlyph: replacementGlyph).width
            }
            
            invisibleLines = generateInvisibleLines()
        }
    }
    
    var invisiblesColor = NSColor.disabledControlTextColor {
        
        didSet {
            invisibleLines = generateInvisibleLines()
        }
    }
    
    private(set) var spaceWidth: CGFloat = 0
    private(set) var replacementGlyphWidth: CGFloat = 0
    private(set) var defaultBaselineOffset: CGFloat = 0  // defaultBaselineOffset for textFont
    private(set) var showsOtherInvisibles = false
    
    
    // MARK: Private Properties
    
//    private var defaultsObservers: [UserDefaultsObservation] = []
    
    private var defaultLineHeight: CGFloat = 1.0
    
    private var showsSpace = false
    private var showsTab = false
    private var showsNewLine = false
    private var showsFullwidthSpace = false
    
    private lazy var invisibleLines: InvisibleLines = generateInvisibleLines()
    
    
    private struct InvisibleLines {
        
        let space: CTLine
        let tab: CTLine
        let newLine: CTLine
        let fullwidthSpace: CTLine
        let replacement: CTLine
    }
    
    
    
    // MARK: -
    // MARK: Lifecycle
    
    override init() {
        
        super.init()
        
        applyDefaultInvisiblesSetting()
        
        // Since NSLayoutManager's showsControlCharacters flag is totally buggy (at least on El Capitan),
        // we stopped using it since CotEditor 2.3.3 released in 2016-01.
        // Previously, CotEditor used this flag for "Other Invisible Characters."
        // However, as CotEditor draws such control-glyph-alternative-characters by itself in `drawGlyphs(forGlyphRange:at:)`,
        // this flag is actually not so necessary as I thougth. Thus, treat carefully this.
        showsControlCharacters = false
        
      //  self.typesetter = ATSTypesetter()
        
//        // observe change in defaults
//        let defaultKeys: [DefaultKeys] = [
//            .invisibleSpace,
//            .invisibleTab,
//            .invisibleNewLine,
//            .invisibleFullwidthSpace,
//
//            .showInvisibleSpace,
//            .showInvisibleTab,
//            .showInvisibleNewLine,
//            .showInvisibleFullwidthSpace,
//
//            .showOtherInvisibleChars,
//            ]
//        self.defaultsObservers = UserDefaults.standard.observe(keys: defaultKeys) { [unowned self] (key, _) in
//            self.applyDefaultInvisiblesSetting()
//            self.invisibleLines = self.generateInvisibleLines()
//
//            guard let textView = self.firstTextView else { return }
//
//            if key == .showOtherInvisibleChars {
//                self.invalidateLayout(forCharacterRange: self.attributedString().range, actualCharacterRange: nil)
//            }
//            textView.setNeedsDisplay(textView.visibleRect, avoidAdditionalLayout: (key != .showOtherInvisibleChars))
//        }
    }
    
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    deinit {
//        self.defaultsObservers.forEach { $0.invalidate() }
//    }
    
    
    
    // MARK: Layout Manager Methods
    
    /// adjust rect of last empty line
    override func setExtraLineFragmentRect(_ fragmentRect: NSRect, usedRect: NSRect, textContainer container: NSTextContainer) {
        
        // -> height of the extra line fragment should be the same as normal other fragments that are likewise customized in ATSTypesetter
        var fragmentRect = fragmentRect
        fragmentRect.size.height = lineHeight
        var usedRect = usedRect
        usedRect.size.height = lineHeight
        
        super.setExtraLineFragmentRect(fragmentRect, usedRect: usedRect, textContainer: container)
    }
    
    
    /// draw glyphs
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint) {
    
        NSGraphicsContext.saveGraphicsState()
        
        // set anti-alias state on screen drawing
        if NSGraphicsContext.currentContextDrawingToScreen() {
            NSGraphicsContext.current?.shouldAntialias = usesAntialias
        }
        
        // draw invisibles
        if showsInvisibles,
            let context = NSGraphicsContext.current?.cgContext,
            let string = textStorage?.string as NSString?
        {
            let isVertical = (firstTextView?.layoutOrientation == .vertical)
            let isRTL = (firstTextView?.baseWritingDirection == .rightToLeft)
            let isOpaque = firstTextView?.isOpaque ?? true
            
            if !isOpaque {
                context.setShouldSmoothFonts(false)
            }
            
            // flip coordinate if needed
            if NSGraphicsContext.current?.isFlipped ?? false {
                context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0)
            }
            
            // draw invisibles glyph by glyph
            for glyphIndex in glyphsToShow.location ..< glyphsToShow.upperBound {
                let charIndex = characterIndexForGlyph(at: glyphIndex)
                let codeUnit = string.character(at: charIndex)
                let invisible = Invisible(codeUnit: codeUnit)
                
                let line: CTLine
                switch invisible {
                case .space?:
                    guard showsSpace else { continue }
                    line = invisibleLines.space
                    
                case .tab?:
                    guard showsTab else { continue }
                    line = invisibleLines.tab
                    
                case .newLine?:
                    guard showsNewLine else { continue }
                    line = invisibleLines.newLine
                    
                case .fullwidthSpace?:
                    guard showsFullwidthSpace else { continue }
                    line = invisibleLines.fullwidthSpace
                    
                default:
                    guard showsOtherInvisibles else { continue }
                    guard propertyForGlyph(at: glyphIndex) == .controlCharacter else { continue }
                    line = invisibleLines.replacement
                }
                
                // calculate position to draw glyph
                let lineOrigin = lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil, withoutAdditionalLayout: true).origin
                let glyphLocation = location(forGlyphAt: glyphIndex)
                var point = lineOrigin.offset(by: origin).offsetBy(dx: glyphLocation.x,
                                                                   dy: defaultBaselineOffset)
                if isVertical {
                   point.y += line.bounds(options: .useGlyphPathBounds).height / 2
                }
                if isRTL, invisible == .newLine {
                    point.x -= line.bounds().width
                }
                
                // draw character
                context.textPosition = point
                CTLineDraw(line, context)
            }
            
            if !isOpaque {
                context.setShouldSmoothFonts(true)
            }
        }
        
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        
        NSGraphicsContext.restoreGraphicsState()
    }
    
    
    /// fill background rectangles with a color
    override func fillBackgroundRectArray(_ rectArray: UnsafePointer<NSRect>, count rectCount: Int, forCharacterRange charRange: NSRange, color: NSColor) {
        
        // modify selected highlight color when document is inactive
        // -> Otherwise, `.secondarySelectedControlColor` will be used forcely and text becomes unreadable in a dark theme.
        if NSAppKitVersion.current <= .macOS10_13,
            color == .secondarySelectedControlColor,  // check if inactive
            let theme = (textViewForBeginningOfSelection as? Themable)?.theme,
            let secondarySelectionColor = theme.secondarySelectionColor
        {
            secondarySelectionColor.setFill()
        }
    
        super.fillBackgroundRectArray(rectArray, count: rectCount, forCharacterRange: charRange, color: color)
    }
    
    
    /// invalidate display for the given character range
    override func invalidateDisplay(forCharacterRange charRange: NSRange) {
        
        // ignore display validation during applying temporary attributes continuously
        // -> See `SyntaxParser.apply(highlights:range:)` for the usage of this option. (2018-12)
        if ignoresDisplayValidation {
            return
        }
        
        super.invalidateDisplay(forCharacterRange: charRange)
    }
    
    
    
    // MARK: Public Methods
    
    /// return fixed line height to avoid having different line height by composite font
    var lineHeight: CGFloat {
        
        let multiple = firstTextView?.defaultParagraphStyle?.lineHeightMultiple ?? 1.0
        
        return 1.5 //multiple * defaultLineHeight
    }
    
    
    
    // MARK: Private Methods
    
    /// apply invisible settings
    private func applyDefaultInvisiblesSetting() {
//        let defaults = UserDefaults.standard
//        // `showsInvisibles` will be set from EditorTextView or PrintTextView
//        self.showsSpace = defaults[.showInvisibleSpace]
//        self.showsTab = defaults[.showInvisibleTab]
//        self.showsNewLine = defaults[.showInvisibleNewLine]
//        self.showsFullwidthSpace = defaults[.showInvisibleFullwidthSpace]
//        self.showsOtherInvisibles = defaults[.showOtherInvisibleChars]
    }
    
    
    /// cache CTLines for invisible characters drawing
    private func generateInvisibleLines() -> InvisibleLines {

        let fontSize = textFont?.pointSize ?? 0
        let font = NSFont.systemFont(ofSize: fontSize)
        let textFont = self.textFont ?? font
        let fullWidthFont = NSFont.systemFont(ofSize: fontSize)

        return InvisibleLines(space: invisibleLine(.space, font: textFont),
                              tab: invisibleLine(.tab, font: font),
                              newLine: invisibleLine(.newLine, font: font),
                              fullwidthSpace: invisibleLine(.fullwidthSpace, font: fullWidthFont),
                              replacement: invisibleLine(.replacement, font: textFont))
    }
    
    
    /// create CTLine for given invisible type
    private func invisibleLine(_ invisible: Invisible, font: NSFont) -> CTLine {
        
        return CTLine.create(string: invisible.usedSymbol, color: invisiblesColor, font: font)
    }
    
}



// MARK: -

private extension CTLine {
    
    /// convenient initializer for CTLine
    class func create(string: String, color: NSColor, font: NSFont) -> CTLine {
        
        let attrString = NSAttributedString(string: string, attributes: [.foregroundColor: color,
                                                                         .font: font])
        
        return CTLineCreateWithAttributedString(attrString)
    }
    
    
    /// get bounds in a objective way.
    func bounds(options: CTLineBoundsOptions = []) -> CGRect {
        
        return CTLineGetBoundsWithOptions(self, options)
    }
    
}
