//
//  Pair.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

struct Pair<T> {
    
    var begin: T
    var end: T
    
    
    init(_ begin: T, _ end: T) {
        
        self.begin = begin
        self.end = end
    }
}


extension Pair: Equatable where T: Equatable { }



// MARK: BracePair

typealias BracePair = Pair<Character>

extension Pair where T == Character {
    
    static let braces: [BracePair] = [BracePair("(", ")"),
                                      BracePair("{", "}"),
                                      BracePair("[", "]")]
    static let ltgt = BracePair("<", ">")
    static let doubleQuotes = BracePair("\"", "\"")
    
    
    enum PairIndex {
        
        case begin(String.Index)
        case end(String.Index)
        case odd
    }
    
}



extension StringProtocol where Self.Index == String.Index {
    
    ///
    func indexOfBracePair(at index: Index, candidates: [BracePair], in range: Range<Index>? = nil, ignoring pairToIgnore: BracePair? = nil) -> BracePair.PairIndex? {
        
        guard !self.isCharacterEscaped(at: index) else { return nil }
        
        let character = self[index]
        
        guard let pair = candidates.first(where: { $0.begin == character || $0.end == character }) else { return nil }
        
        switch character {
        case pair.begin:
            guard let endIndex = self.indexOfBracePair(beginIndex: index, pair: pair, until: range?.upperBound, ignoring: pairToIgnore) else { return .odd }
            return .end(endIndex)
            
        case pair.end:
            guard let beginIndex = self.indexOfBracePair(endIndex: index, pair: pair, until: range?.lowerBound, ignoring: pairToIgnore) else { return .odd }
            return .begin(beginIndex)
            
        default: preconditionFailure()
        }
    }
    
    
    /// find character index of matched opening brace before a given index.
    func indexOfBracePair(endIndex: Index, pair: BracePair, until beginIndex: Index? = nil, ignoring pairToIgnore: BracePair? = nil) -> Index? {
        
        let beginIndex = beginIndex ?? self.startIndex
        
        guard beginIndex < endIndex else { return nil }
        
        var nestDepth = 0
        var ignoredNestDepth = 0
        let subsequence = self[beginIndex..<endIndex]
        
        for (index, character) in zip(subsequence.indices, subsequence).reversed() {
            switch character {
            case pair.begin where ignoredNestDepth == 0:
                guard !self.isCharacterEscaped(at: index) else { continue }
                if nestDepth == 0 { return index }  // found
                nestDepth -= 1
                
            case pair.end where ignoredNestDepth == 0:
                guard !self.isCharacterEscaped(at: index) else { continue }
                nestDepth += 1
                
            case pairToIgnore?.begin:
                guard !self.isCharacterEscaped(at: index) else { continue }
                ignoredNestDepth -= 1
                
            case pairToIgnore?.end:
                guard !self.isCharacterEscaped(at: index) else { continue }
                ignoredNestDepth += 1
                
            default: break
            }
        }
        
        return nil
    }
    
    
    /// find character index of matched closing brace after a given index.
    func indexOfBracePair(beginIndex: Index, pair: BracePair, until endIndex: Index? = nil, ignoring pairToIgnore: BracePair? = nil) -> Index? {
        
        let endIndex = endIndex ?? self.endIndex
        
        guard beginIndex < endIndex else { return nil }
        
        var nestDepth = 0
        var ignoredNestDepth = 0
        let subsequence = self[self.index(after: beginIndex)..<endIndex]
        
        for (index, character) in zip(subsequence.indices, subsequence) {
            switch character {
            case pair.end where ignoredNestDepth == 0:
                guard !self.isCharacterEscaped(at: index) else { continue }
                if nestDepth == 0 { return index }  // found
                nestDepth -= 1
                
            case pair.begin where ignoredNestDepth == 0:
                guard !self.isCharacterEscaped(at: index) else { continue }
                nestDepth += 1
                
            case pairToIgnore?.end:
                guard !self.isCharacterEscaped(at: index) else { continue }
                ignoredNestDepth -= 1
                
            case pairToIgnore?.begin:
                guard !self.isCharacterEscaped(at: index) else { continue }
                ignoredNestDepth += 1
                
            default: break
            }
        }
        
        return nil
    }
    
}
