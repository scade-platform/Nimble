//
//  Comparable.swift
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

extension Comparable {
    
    /// Return clamped value to min/max values.
    ///
    /// - Parameter range: Condition which receiver should be in between.
    /// - Returns: Processed value.
    func clamped(to range: ClosedRange<Self>) -> Self {
        
        return max(range.lowerBound, min(self, range.upperBound))
    }
}
