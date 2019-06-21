//
//  OutlineParseOperation.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

final class OutlineParseOperation: Operation, ProgressReporting {
    
    // MARK: Public Properties
    
    let progress: Progress
    private(set) var results = [OutlineItem]()
    
    
    // MARK: Private Properties
    
    private let extractors: [OutlineExtractor]
    private let string: String
    private let parseRange: NSRange
    
    
    
    // MARK: -
    // MARK: Lifecycle
    
    required init(extractors: [OutlineExtractor], string: String, range parseRange: NSRange) {
        
        assert(parseRange.location != NSNotFound)
        
        self.extractors = extractors
        self.string = string
        self.parseRange = parseRange
        
        self.progress = Progress(totalUnitCount: Int64(extractors.count + 1))
        
        super.init()
        
        self.progress.cancellationHandler = { [weak self] in
            self?.cancel()
        }
    }
    
    
    
    // MARK: Operation Methods
    
    /// is ready to run
    override var isReady: Bool {
        
        return true
    }
    
    
    /// parse string and extract outline items
    override func main() {
        
        guard
            !self.extractors.isEmpty,
            !self.string.isEmpty
            else {
                self.progress.completedUnitCount = self.progress.totalUnitCount
                return
            }
        
        for extractor in self.extractors {
            guard !self.isCancelled else { return }
            
            self.results += extractor.items(in: self.string, range: self.parseRange) { (stop) in
                stop = self.isCancelled
            }
            
            self.progress.completedUnitCount += 1
        }
        
        guard !self.isCancelled else { return }
        
        self.results.sort {
            $0.range.location < $1.range.location
        }
        
        self.progress.completedUnitCount += 1
    }
    
}
