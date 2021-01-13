//
//  Keycode.swift
//  CodeEditor.plugin

//  Gist from: https://gist.github.com/swillits/df648e87016772c7f7e5dbed2b345066


// MARK: - Keycodes

public struct Keycode {
  
  // Layout-independent Keys
  // eg.These key codes are always the same key on all layouts.
  public static let returnKey                 : UInt16 = 0x24
  public static let enter                     : UInt16 = 0x4C
  public static let tab                       : UInt16 = 0x30
  public static let space                     : UInt16 = 0x31
  public static let delete                    : UInt16 = 0x33
  public static let escape                    : UInt16 = 0x35
  public static let command                   : UInt16 = 0x37
  public static let shift                     : UInt16 = 0x38
  public static let capsLock                  : UInt16 = 0x39
  public static let option                    : UInt16 = 0x3A
  public static let control                   : UInt16 = 0x3B
  public static let rightShift                : UInt16 = 0x3C
  public static let rightOption               : UInt16 = 0x3D
  public static let rightControl              : UInt16 = 0x3E
  public static let leftArrow                 : UInt16 = 0x7B
  public static let rightArrow                : UInt16 = 0x7C
  public static let downArrow                 : UInt16 = 0x7D
  public static let upArrow                   : UInt16 = 0x7E
  public static let volumeUp                  : UInt16 = 0x48
  public static let volumeDown                : UInt16 = 0x49
  public static let mute                      : UInt16 = 0x4A
  public static let help                      : UInt16 = 0x72
  public static let home                      : UInt16 = 0x73
  public static let pageUp                    : UInt16 = 0x74
  public static let forwardDelete             : UInt16 = 0x75
  public static let end                       : UInt16 = 0x77
  public static let pageDown                  : UInt16 = 0x79
  public static let function                  : UInt16 = 0x3F
  public static let f1                        : UInt16 = 0x7A
  public static let f2                        : UInt16 = 0x78
  public static let f4                        : UInt16 = 0x76
  public static let f5                        : UInt16 = 0x60
  public static let f6                        : UInt16 = 0x61
  public static let f7                        : UInt16 = 0x62
  public static let f3                        : UInt16 = 0x63
  public static let f8                        : UInt16 = 0x64
  public static let f9                        : UInt16 = 0x65
  public static let f10                       : UInt16 = 0x6D
  public static let f11                       : UInt16 = 0x67
  public static let f12                       : UInt16 = 0x6F
  public static let f13                       : UInt16 = 0x69
  public static let f14                       : UInt16 = 0x6B
  public static let f15                       : UInt16 = 0x71
  public static let f16                       : UInt16 = 0x6A
  public static let f17                       : UInt16 = 0x40
  public static let f18                       : UInt16 = 0x4F
  public static let f19                       : UInt16 = 0x50
  public static let f20                       : UInt16 = 0x5A
  
  // US-ANSI Keyboard Positions
  // eg. These key codes are for the physical key (in any keyboard layout)
  // at the location of the named key in the US-ANSI layout.
  public static let a                         : UInt16 = 0x00
  public static let b                         : UInt16 = 0x0B
  public static let c                         : UInt16 = 0x08
  public static let d                         : UInt16 = 0x02
  public static let e                         : UInt16 = 0x0E
  public static let f                         : UInt16 = 0x03
  public static let g                         : UInt16 = 0x05
  public static let h                         : UInt16 = 0x04
  public static let i                         : UInt16 = 0x22
  public static let j                         : UInt16 = 0x26
  public static let k                         : UInt16 = 0x28
  public static let l                         : UInt16 = 0x25
  public static let m                         : UInt16 = 0x2E
  public static let n                         : UInt16 = 0x2D
  public static let o                         : UInt16 = 0x1F
  public static let p                         : UInt16 = 0x23
  public static let q                         : UInt16 = 0x0C
  public static let r                         : UInt16 = 0x0F
  public static let s                         : UInt16 = 0x01
  public static let t                         : UInt16 = 0x11
  public static let u                         : UInt16 = 0x20
  public static let v                         : UInt16 = 0x09
  public static let w                         : UInt16 = 0x0D
  public static let x                         : UInt16 = 0x07
  public static let y                         : UInt16 = 0x10
  public static let z                         : UInt16 = 0x06
      
  public static let zero                      : UInt16 = 0x1D
  public static let one                       : UInt16 = 0x12
  public static let two                       : UInt16 = 0x13
  public static let three                     : UInt16 = 0x14
  public static let four                      : UInt16 = 0x15
  public static let five                      : UInt16 = 0x17
  public static let six                       : UInt16 = 0x16
  public static let seven                     : UInt16 = 0x1A
  public static let eight                     : UInt16 = 0x1C
  public static let nine                      : UInt16 = 0x19
  
  public static let equals                    : UInt16 = 0x18
  public static let minus                     : UInt16 = 0x1B
  public static let semicolon                 : UInt16 = 0x29
  public static let apostrophe                : UInt16 = 0x27
  public static let comma                     : UInt16 = 0x2B
  public static let period                    : UInt16 = 0x2F
  public static let forwardSlash              : UInt16 = 0x2C
  public static let backslash                 : UInt16 = 0x2A
  public static let grave                     : UInt16 = 0x32
  public static let leftBracket               : UInt16 = 0x21
  public static let rightBracket              : UInt16 = 0x1E
  
  public static let keypadDecimal             : UInt16 = 0x41
  public static let keypadMultiply            : UInt16 = 0x43
  public static let keypadPlus                : UInt16 = 0x45
  public static let keypadClear               : UInt16 = 0x47
  public static let keypadDivide              : UInt16 = 0x4B
  public static let keypadEnter               : UInt16 = 0x4C
  public static let keypadMinus               : UInt16 = 0x4E
  public static let keypadEquals              : UInt16 = 0x51
  public static let keypad0                   : UInt16 = 0x52
  public static let keypad1                   : UInt16 = 0x53
  public static let keypad2                   : UInt16 = 0x54
  public static let keypad3                   : UInt16 = 0x55
  public static let keypad4                   : UInt16 = 0x56
  public static let keypad5                   : UInt16 = 0x57
  public static let keypad6                   : UInt16 = 0x58
  public static let keypad7                   : UInt16 = 0x59
  public static let keypad8                   : UInt16 = 0x5B
  public static let keypad9                   : UInt16 = 0x5C
  
  
  // MARK: - Key sets
  
  public static let chars = [
    a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
  ]
}
