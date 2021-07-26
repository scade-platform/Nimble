//
//  String+Regex.swift
//  
//
//  Created by Danil Kristalev on 26.07.2021.
//

import Foundation


public extension String {
  var asRegex: NSRegularExpression? {
    guard let regex = try? NSRegularExpression(pattern: self) else {
      return nil
    }
    return regex
  }
}
