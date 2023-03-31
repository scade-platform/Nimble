//
//  KeyPathDecodable.swift
//  NimbleCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public struct RawCodingKey: CodingKey, Equatable {
  public var intValue: Int? = nil
  public let stringValue: String
    
  public init?(intValue: Int) {
    return nil
  }
  
  public init?(stringValue: String) {
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
