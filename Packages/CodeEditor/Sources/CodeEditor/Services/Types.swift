//
//  File.swift
//  
//
//  Created by Grigory Markin on 12.06.20.
//

import Foundation


public enum Documentation {
  case plaintext(String)
  case markdown(String)
}


public protocol TextEdit {
  var newText: String { get }
  func range(`in`: String) -> Range<Int>
}


