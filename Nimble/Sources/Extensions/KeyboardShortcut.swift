//
//  KeyboardShortcut.swift
//  Nimble
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

import Cocoa
import NimbleCore


extension KeyboardShortcut {
  var keyEquivalent: (key: String, flags: NSEvent.ModifierFlags) {
    return (self.key, NSEvent.ModifierFlags(modifiers.map() { $0.flag }))
  }
}

extension KeyboardShortcut.Modifier {
  var flag: NSEvent.ModifierFlags {
    switch self {
    case .capsLock: return .capsLock
    case .shift: return .shift
    case .control: return .control
    case .option: return .control
    case .command: return .command
    case .numericPad: return .numericPad
    case .help: return .help
    case .function: return .function
    }
  }
}

// MARK: - NSEvent

extension NSEvent {
  var keyboardShortcut: KeyboardShortcut? {
    guard let key = self.charactersIgnoringModifiers else {
      return nil
    }
    
    return KeyboardShortcut(key, modifiers: self.modifierFlags.modifiers)
  }
}


extension NSEvent.ModifierFlags {
  var modifiers: Set<KeyboardShortcut.Modifier> {
    var modifiers = Set<KeyboardShortcut.Modifier>()

    if self.contains(.capsLock) {
      modifiers.insert(.capsLock)
    }

    if self.contains(.shift) {
      modifiers.insert(.shift)
    }

    if self.contains(.control) {
      modifiers.insert(.control)
    }

    if self.contains(.command) {
      modifiers.insert(.command)
    }

    if self.contains(.numericPad) {
      modifiers.insert(.numericPad)
    }

    if self.contains(.help) {
      modifiers.insert(.help)
    }

    if self.contains(.function) {
      modifiers.insert(.function)
    }

    return modifiers
  }
}
