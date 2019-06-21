//
//  SyntaxParser.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation
import AppKit.NSTextStorage

protocol ValidationIgnorable: NSLayoutManager {
    
    var ignoresDisplayValidation: Bool { get set }
}

class SyntaxParser {
    // MARK: Public Properties
    
    let textStorage: NSTextStorage
    var style: SyntaxStyle
    
    init(textStorage: NSTextStorage, style: SyntaxStyle) {
        self.textStorage = textStorage
        self.style = style
        
        outlineParseOperationQueue = OperationQueue()
        outlineParseOperationQueue.name = "outlineParseOperationQueue"
        syntaxHighlightParseOperationQueue = OperationQueue()
        syntaxHighlightParseOperationQueue.name = "syntaxHighlightParseOperationQueue"
    }
    
    deinit {
        invalidateCurrentParse()
    }
    
    // MARK: Public Methods
    
    /// whether enable parsing syntax
    var canParse: Bool {
        return !style.isNone
    }
    
    // MARK: Private
    
    private var highlightCache: Cache?  // results cache of the last whole string highlights
    
    private struct Cache {
        var styleName: String
        var string: String
        var highlights: [SyntaxType: [NSRange]]
    }
    
    private lazy var outlineUpdateTask = Debouncer(delay: .milliseconds(400)) { [weak self] in
        //self?.parseOutline()
    }
    
    private let outlineParseOperationQueue: OperationQueue
    private let syntaxHighlightParseOperationQueue: OperationQueue
    
    private(set) var outlineItems: [OutlineItem] = [] {
        didSet {
            // inform about outline items update
            DispatchQueue.main.async { [weak self, items = outlineItems] in
                guard let self = self else { return assertionFailure() }
                
                //self.delegate?.syntaxParser(self, didParseOutline: items)
                //NotificationCenter.default.post(name: SyntaxParser.didUpdateOutlineNotification, object: self)
            }
        }
    }
    
    /// cancel all syntax parse
    func invalidateCurrentParse() {
        highlightCache = nil
        outlineUpdateTask.cancel()
        outlineParseOperationQueue.cancelAllOperations()
        syntaxHighlightParseOperationQueue.cancelAllOperations()
    }
}

// MARK: - Outline

extension SyntaxParser {
    
    /// parse outline with delay
    func invalidateOutline() {
        
        guard canParse, !style.outlineExtractors.isEmpty else {
            outlineItems = []
            return
        }
        
        outlineUpdateTask.schedule()
    }
    

    // MARK: Private Methods
    
    /// parse outline
    private func parseOutline() {
        
        let wholeRange = textStorage.range
        guard wholeRange.length != 0 else {
            outlineItems = []
            return
        }
        
        let operation = OutlineParseOperation(extractors: style.outlineExtractors,
                                              string: textStorage.string.immutable,
                                              range: wholeRange)
        
        operation.completionBlock = { [weak self, weak operation] in
            guard let operation = operation, !operation.isCancelled else { return }
            
            self?.outlineItems = operation.results
        }
        operation.qualityOfService = .utility
        
        // -> Regarding the outline extraction, just cancel previous operations before pasing the latest string,
        //    since user cannot cancel it manually.
        self.outlineParseOperationQueue.cancelAllOperations()
        
        self.outlineParseOperationQueue.addOperation(operation)
        
        //self.delegate?.syntaxParser(self, didStartParsingOutline: operation.progress)
    }
    
}

// MARK: - Syntax Highlight

extension SyntaxParser {
    
    /// update whole document highlights
    func highlightAll(completionHandler: @escaping (() -> Void) = {}) -> Progress? {
        
        assert(Thread.isMainThread)
        
       // guard UserDefaults.standard[.enableSyntaxHighlight] else { return nil }
        guard !textStorage.string.isEmpty else { return nil }
        
        let wholeRange = textStorage.range
        
        // use cache if the content of the whole document is the same as the last
        if let cache = highlightCache, cache.styleName == style.name, cache.string == textStorage.string {
            apply(highlights: cache.highlights, range: wholeRange)
            completionHandler()
            return nil
        }
        
        // make sure that string is immutable
        //   -> `string` of NSTextStorage is actually a mutable object
        //      and it can cause crash when a mutable string is given to NSRegularExpression instance.
        //      (2016-11, macOS 10.12.1 SDK)
        let string = textStorage.string.immutable
        
        return highlight(string: string, range: wholeRange, completionHandler: completionHandler)
    }
    
    
    /// update highlights around passed-in range
    func highlight(around editedRange: NSRange) -> Progress? {
        
        assert(Thread.isMainThread)
        
        //guard UserDefaults.standard[.enableSyntaxHighlight] else { return nil }
        guard !textStorage.string.isEmpty else { return nil }
        
        // make sure that string is immutable (see `highlightAll()` for details)
        let string = textStorage.string.immutable
        
        let wholeRange = textStorage.range
        let bufferLength = 5000 //UserDefaults.standard[.coloringRangeBufferLength]
        
        // in case that wholeRange length is changed from editedRange
        guard editedRange.upperBound <= wholeRange.upperBound else { return nil }
        
        var highlightRange = editedRange
        
        // highlight whole if string is enough short
        if wholeRange.length <= bufferLength {
            highlightRange = wholeRange
            
        } else {
            // highlight whole visible area if edited point is visible
            for layoutManager in textStorage.layoutManagers {
                guard let visibleRange = layoutManager.firstTextView?.visibleRange else { continue }
                
                highlightRange.formUnion(visibleRange)
            }
            
            highlightRange = highlightRange.intersection(wholeRange) ?? wholeRange
            highlightRange = (string as NSString).lineRange(for: highlightRange)
            
            // expand highlight area if the character just before/after the highlighting area is the same color
            if let layoutManager = self.textStorage.layoutManagers.first {
                var start = highlightRange.lowerBound
                var end = highlightRange.upperBound
                
                if start <= bufferLength {
                    start = 0
                } else if let effectiveRange = layoutManager.effectiveRange(of: .foregroundColor, at: start) {
                    start = effectiveRange.lowerBound
                }
                
                if let effectiveRange = layoutManager.effectiveRange(of: .foregroundColor, at: end) {
                    end = effectiveRange.upperBound
                }
                
                highlightRange = NSRange(start..<end)
            }
        }
        
        return self.highlight(string: string, range: highlightRange)
    }
    
    
    
    // MARK: Private Methods
    
    /// perform highlighting
    private func highlight(string: String, range highlightRange: NSRange, completionHandler: @escaping (() -> Void) = {}) -> Progress? {
        
        assert(Thread.isMainThread)
        
        guard !highlightRange.isEmpty else { return nil }
        
        // just clear current highlight and return if no coloring needs
        guard self.style.hasHighlightDefinition else {
            self.apply(highlights: [:], range: highlightRange)
            completionHandler()
            return nil
        }
        
        let wholeRange = string.nsRange
        let styleName = self.style.name
        
        let definition = SyntaxHighlightParseOperation.ParseDefinition(extractors: self.style.highlightExtractors,
                                                                       pairedQuoteTypes: self.style.pairedQuoteTypes,
                                                                       inlineCommentDelimiter: self.style.inlineCommentDelimiter,
                                                                       blockCommentDelimiters: self.style.blockCommentDelimiters)
        
        let operation = SyntaxHighlightParseOperation(definition: definition, string: string, range: highlightRange)
        operation.qualityOfService = .userInitiated
        
        // give up if the editor's string is changed from the parsed string
        let isModified = Atomic(false)
        let modificationObserver = NotificationCenter.default.addObserver(forName: NSTextStorage.didProcessEditingNotification, object: self.textStorage, queue: nil) { [weak operation] (note) in
            guard (note.object as! NSTextStorage).editedMask.contains(.editedCharacters) else { return }
            
            isModified.mutate { $0 = true }
            operation?.cancel()
        }
        
        operation.completionBlock = { [weak self, weak operation] in
            guard
                let operation = operation,
                let highlights = operation.highlights,
                !operation.isCancelled
                else {
                    NotificationCenter.default.removeObserver(modificationObserver)
                    return completionHandler()
            }
            
            DispatchQueue.main.async { [progress = operation.progress] in
                defer {
                    NotificationCenter.default.removeObserver(modificationObserver)
                    completionHandler()
                }
                
                guard !isModified.value else {
                    progress.cancel()
                    return
                }
                
                // cache result if whole text was parsed
                if highlightRange == wholeRange {
                    self?.highlightCache = Cache(styleName: styleName, string: string, highlights: highlights)
                }
                
                self?.apply(highlights: highlights, range: highlightRange)
                
                progress.completedUnitCount += 1
            }
        }
        
        self.syntaxHighlightParseOperationQueue.addOperation(operation)
        
        return operation.progress
    }
    
    
    /// apply highlights to the document
    private func apply(highlights: [SyntaxType: [NSRange]], range highlightRange: NSRange) {
        
        assert(Thread.isMainThread)
        
        for layoutManager in self.textStorage.layoutManagers {
            // disable display validation during applying attributes
            // -> According to the implementation of NSLayoutManager in GNUstep,
            //    `invalidateDisplayForCharacterRange:` is invoked every time inside of `addTemporaryAttribute:value:forCharacterRange:`.
            //    Ignoring that process during highlight reduces the application time,
            //    which shows the rainbow cursor because of a main thread task, significantly.
            //    See `LayoutManager.invalidateDisplay(forCharacterRange:)` for the LayoutManager-side implementation.
            //    (2018-12 macOS 10.14)
            if let layoutManager = layoutManager as? ValidationIgnorable {
                layoutManager.ignoresDisplayValidation = true
            }
            defer {
                if let layoutManager = layoutManager as? ValidationIgnorable {
                    layoutManager.ignoresDisplayValidation = false
                    layoutManager.invalidateDisplay(forCharacterRange: highlightRange)
                }
            }
            
            layoutManager.removeTemporaryAttribute(.foregroundColor, forCharacterRange: highlightRange)
            
//            guard let theme = (layoutManager.firstTextView as? Themable)?.theme else {
//                continue
//            }
            
            guard let theme = ThemeManager.shared.theme else {
                continue
            }
            
            for type in SyntaxType.allCases {
                guard let ranges = highlights[type], !ranges.isEmpty else {
                    continue
                }
                
                if let color = theme.style(for: type)?.color {
                    for range in ranges {
                        layoutManager.addTemporaryAttribute(.foregroundColor, value: color, forCharacterRange: range)
                    }
                } else {
                    for range in ranges {
                        layoutManager.removeTemporaryAttribute(.foregroundColor, forCharacterRange: range)
                    }
                }
            }
        }
    }
    
}
