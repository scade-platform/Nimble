//
//  KeyboardShortcut.swift
//  NimbleCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
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

public struct KeyboardShortcut: Hashable {
  public enum Modifier: String {
    case capsLock, shift, control, option, command, numericPad, help, function

    static func parse<T: StringProtocol>(_ str: T) -> Modifier? {
      if let mod = self.init(rawValue: String(str)) {
        return mod
      }

      switch str {
      case "ctrl":
        return .control
      case "cmd":
        return .command
      case "fn":
        return .function
      case "num", "numPad":
        return .numericPad
      default:
        return nil
      }
    }
  }

  private struct Key {
    static func parse<T: StringProtocol>(_ str: T) -> String? {
      ///TODO: add more checks for valid keys
      switch str {
      case "plus": return "+"
      case "minus": return "-"
      default:
        return String(str)
      }
    }
  }

  public let key: String
  public let modifiers: Set<Modifier>

  public init<T: Sequence>(_ key: String, modifiers: T) where T.Element == Modifier {
    self.key = key.lowercased()
    self.modifiers = Set<Modifier>(modifiers)
  }
  
  public init?(_ str: String) {
    var key: String? = nil
    var modifiers = Set<Modifier>()

    let keys = str.lowercased().replacingOccurrences(of: " ", with: "").split(separator: "+")

    for k in keys {
      if let mod = Modifier.parse(k) {
        modifiers.insert(mod)
      } else if key == nil {
        key = Key.parse(k)
      } else {
        return nil
      }
    }

    guard let k = key else { return nil }
    self.init(k, modifiers: modifiers)
  }
}
