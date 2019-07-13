//
//  String+Ranges.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 11.07.19.
//

import Foundation

public extension String {
  var range: Range<Int> {return 0..<self.count}
  
  var nsRange: NSRange { return NSRange(self.range) }
}
