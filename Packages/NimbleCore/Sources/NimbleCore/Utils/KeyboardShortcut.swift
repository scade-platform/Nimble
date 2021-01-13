//
//  KeyboardShortcut.swift
//  
//
//  Created by Grigory Markin on 29.10.20.
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
