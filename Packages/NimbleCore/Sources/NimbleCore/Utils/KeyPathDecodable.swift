//
//  KeyPathDecodable.swift
//  NimbleCore
//
//  Created by Grigory Markin on 04.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

private struct RawCodingKey: CodingKey, Equatable {
  var intValue: Int? = nil
  let stringValue: String
    
  init?(intValue: Int) {
    return nil
  }
  
  init?(stringValue: String) {
    self.stringValue = stringValue
  }
}

public struct KeyPathDecodable<T: Decodable>: Decodable {
  public var value: T? = nil
  
  public init(from decoder: Decoder) throws {
    let keyPath = decoder.userInfo[.keyPath] as? String
    
    guard var keys = keyPath?.split(separator: "/"),
          let valueKey = keys.popLast() else {
      value = try T(from: decoder)
      return
    }
        
    var container = try decoder.container(keyedBy: RawCodingKey.self)
    for k in keys {
      let key = RawCodingKey(stringValue: String(k))!
      guard container.allKeys.contains(key) else { return }
      container = try container.nestedContainer(keyedBy: RawCodingKey.self, forKey: key)
    }
    
    value = try container.decodeIfPresent(T.self, forKey: RawCodingKey(stringValue: String(valueKey))!)
  }
}

public extension CodingUserInfoKey {
  static let keyPath = CodingUserInfoKey(rawValue: "com.nimble.core.KeyPath")!
}
