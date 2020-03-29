//
//  Theme.swift
//  NimbleCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import ColorCode


public final class Theme: Decodable {
  public var name: String
  //public var light: Bool?
  public var settings: [ColorSettings]
    
  public var path: Path? = nil
  
  public lazy var general: GeneralColorSettings =
    GeneralColorSettings(settings.first{$0.parameters.isEmpty})
}


public final class ColorSettings: Decodable {
  fileprivate enum CodingKeys: String, CodingKey {
    case name, settings
  }
  
  public var name: String?
  public var settings: [String: String]
  public var parameters: [String: String]
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.settings = try container.decode([String: String].self, forKey: .settings)
        
    let untypedContainer = try decoder.container(keyedBy: RawCodingKey.self)
    
    self.parameters = [:]
    untypedContainer.allKeys.forEach {
      if CodingKeys(stringValue: $0.stringValue) == nil,
          let value = try? untypedContainer.decode(String.self, forKey: $0) {
        self.parameters[$0.stringValue] = value
      }
    }
  }
  
  public func color(_ key: String) -> NSColor? {
    guard let colorCode = settings[key] else { return nil }
    return NSColor(colorCode: colorCode)
  }
  
  public func color(_ key: String, default defaultColor: NSColor) -> NSColor {
    return self.color(key) ?? defaultColor
  }

  public func fontName() -> String? {
    return settings["fontName"]
  }

  public func fontSize() -> Float? {
    return settings["fontSize"].flatMap { Float($0) }
  }
}

// MARK: - GeneralColorSettings

public struct GeneralColorSettings {
  private weak var settings: ColorSettings?
  
  fileprivate init(_ settings: ColorSettings?) {
    self.settings = settings
  }
  
  public lazy var foreground: NSColor = settings?.color("foreground") ?? .textColor
  public lazy var background: NSColor = settings?.color("background") ?? .textBackgroundColor
  public lazy var caret: NSColor = settings?.color("caret") ?? .textColor
  public lazy var lineHighlight: NSColor = settings?.color("lineHighlight") ?? .clear
  public lazy var selection: NSColor = settings?.color("selection") ?? .selectedTextBackgroundColor
  public lazy var invisibles: NSColor = settings?.color("invisibles") ?? .clear

  public lazy var font: NSFont = {
    let fontName = settings?.fontName() ?? "SFMono-Medium"
    let fontSize = CGFloat(settings?.fontSize() ?? 12)

    return
      NSFont.init(name: fontName, size: fontSize) ??
      NSFont.systemFont(ofSize: fontSize)
  }()
}


// MARK: - Decoders

protocol ThemeDecoder {
  static func decode(from: Path) -> Theme?
}

extension PropertyListDecoder: ThemeDecoder { }
extension YAMLDecoder: ThemeDecoder { }
extension JSONDecoder: ThemeDecoder { }

// MARK: - ThemeManager

public final class ThemeManager {
  
  private let decoders: [String: ThemeDecoder.Type]  = [
    ".thTheme": PropertyListDecoder.self,
    ".tmTheme.yml": YAMLDecoder.self,
    ".thTheme.json": JSONDecoder.self
  ]
    
  public var observers = ObserverSet<ThemeObserver>()
  
  public var themes: [Theme] = []
  
  public var defaultTheme: Theme? {
    switch NSView.systemInterfaceStlye {
    case .dark:
      return themes.first{$0.name == "Default(Dark)"}
    default:
      return themes.first{$0.name == "Default(Light)"}
    }
  }
    
  public var selectedTheme: Theme? {
    didSet {
      UserDefaults.standard.set(selectedTheme?.path?.url, forKey: "colorTheme")
      guard let theme = selectedTheme ?? defaultTheme else { return }
      observers.notify {
        $0.themeDidChanged(theme)
      }
    }
  }
  
  public var currentTheme: Theme? {
    selectedTheme ?? defaultTheme
  }
  
  public static let shared = ThemeManager()
  
  public func load(from path: Path) {
    guard path.isDirectory else { return }
    
    do {
      try path.ls().files.forEach { path in
        guard let decoder = decoders.first(where: { path.basename().hasSuffix($0.key) })?.value,
              let theme = decoder.decode(from: path) else { return }
        
        theme.path = path
        themes.append(theme)
      }
    } catch {}
    
    if let themeURL = UserDefaults.standard.url(forKey: "colorTheme") {
      selectedTheme = themes.first {
        $0.path?.url == themeURL
      }
    }
  }
}


// MARK: -

public protocol ThemeObserver {
  func themeDidChanged(_ theme: Theme)
}

public extension ThemeObserver {
  func themeDidChanged(_ theme: Theme) {}
}
