//
//  ColorTheme.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 04.07.19.
//


import AppKit
import NimbleCore


public final class ColorTheme: Decodable {
  fileprivate enum CodingKeys: String, CodingKey {
    case name, settings
  }
  
  public var name: String
  public var path: Path? = nil
  
  public var global: GlobalSetting
  public var scopes: [ScopeSetting] = []
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    
    let settings = try container.decode([Setting].self, forKey: .settings)
    var globalSetting: GlobalSetting? = nil
    
    for setting in settings {
      switch(setting) {
      case .global(let global):
        globalSetting = global
      case .scope(let scope):
        scopes.append(scope)
      }
    }
    
    self.global = globalSetting ?? GlobalSetting.default
  }
  
  
  private typealias ColorDecoder<Key> = (Key) throws -> NSColor?
  
  private static func colorDecoder<Key>(for container: KeyedDecodingContainer<Key>) -> ColorDecoder<Key> where Key : CodingKey {
    return {
      guard let color = try container.decodeIfPresent(String.self, forKey: $0) else { return nil }
      return NSColor(colorCode: color)
    }
  }
  
  public enum Setting: Decodable {
    fileprivate enum CodingKeys: String, CodingKey {
      case name, scope, settings
    }
    
    case scope(ScopeSetting)
    case global(GlobalSetting)
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      if container.contains(.name) || container.contains(.scope) {
        self = try .scope(ScopeSetting(from: decoder))
      } else {
        self = try .global(GlobalSetting(from: decoder))
      }
    }
  }
  
  
  public final class GlobalSetting: Decodable {
    
    fileprivate enum CodingKeys: String, CodingKey {
      case foreground, background, caret, lineHighlight, selection, invisibles
    }
    
    public var foreground: NSColor = .textColor
    public var background: NSColor = NSColor.textBackgroundColor
    public var caret: NSColor = NSColor.textColor
    public var lineHighlight: NSColor = NSColor.clear
    public var selection: NSColor = NSColor.selectedTextBackgroundColor
    public var invisibles: NSColor = NSColor.clear
    
    public static let `default` = GlobalSetting()
    
    fileprivate init() {}
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: Setting.CodingKeys.self)
      let settings = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .settings)
      let decode = ColorTheme.colorDecoder(for: settings)
                  
      self.foreground = try decode(.foreground) ?? self.foreground
      self.background = try decode(.background) ?? self.background
      self.caret = try decode(.caret) ?? self.caret
      self.lineHighlight = try decode(.lineHighlight) ?? self.lineHighlight
      self.selection = try decode(.selection) ?? self.selection
      self.invisibles = try decode(.invisibles) ?? self.invisibles
    }
  }
  
  public final class ScopeSetting: Decodable {
    fileprivate enum CodingKeys: String, CodingKey {
      case foreground, fontStyle
    }
    
    public var name: String
    public var scope: SyntaxScope
    
    public var fontStyle: String?
    public var foreground: NSColor?
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: Setting.CodingKeys.self)
      
      // Decode scope
      self.name = try container.decode(String.self, forKey: .name)
      self.scope = SyntaxScope(try container.decode(String.self, forKey: .scope))
      
      // Decode settings
      let settings = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .settings)
      let decode = ColorTheme.colorDecoder(for: settings)
      
      self.foreground = try decode(.foreground)
      self.fontStyle = try settings.decodeIfPresent(String.self, forKey: .fontStyle)
    }
    
  }
  
}

// MARK: -

protocol ColorThemeDecoder {
  static func decode(from: Path) -> ColorTheme?
}

// MARK: Decoders

extension YAMLDecoder: ColorThemeDecoder {
  static func decode(from file: Path) -> ColorTheme? {
    guard let content = try? String(contentsOf: file) else { return nil }
    do {
      return try YAMLDecoder().decode(ColorTheme.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}

extension PropertyListDecoder: ColorThemeDecoder {
  static func decode(from file: Path) -> ColorTheme? {
    guard let content = try? Data(contentsOf: file) else { return nil }
    
    do {
      return try PropertyListDecoder().decode(ColorTheme.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}

extension JSONDecoder: ColorThemeDecoder {
  static func decode(from file: Path) -> ColorTheme? {
    guard let content = try? Data(contentsOf: file) else { return nil }
    
    do {
      return try JSONDecoder().decode(ColorTheme.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}


// MARK: Extensions

public extension ColorTheme {
  func setting(for scope: SyntaxScope) -> ScopeSetting? {
    var res: ScopeSetting? = nil
    for s in scopes where s.scope.contains(scope) {
      guard let rs = res?.scope else { res = s; continue }
      if rs.value.count < s.scope.value.count {
        res = s
      }
    }
    return res
  }
}


// MARK: -

public final class ColorThemeManager {
  
  private let decoders: [String: ColorThemeDecoder.Type]  = [
    ".thTheme": PropertyListDecoder.self,
    ".tmTheme.yml": YAMLDecoder.self,
    ".thTheme.json": JSONDecoder.self
  ]
    
  public var observers = ObserverSet<ColorThemeObserver>()
  
  public var colorThemes: [ColorTheme] = []
  
  public var defaultTheme: ColorTheme? {
    let style = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
    return colorThemes.first{$0.name == "Default(\(style))"}
  }
    
  public var selectedTheme: ColorTheme? {
    didSet {
      UserDefaults.standard.set(selectedTheme?.path?.url, forKey: "colorTheme")
      guard let theme = selectedTheme ?? defaultTheme else { return }
      observers.notify {
        $0.colorThemeDidChanged(theme)
      }
    }
  }
  
  public var currentTheme: ColorTheme? {
    selectedTheme ?? defaultTheme
  }
  
  public static let shared = ColorThemeManager()
  
  public func load(from path: Path) {
    guard path.isDirectory else { return }
    
    do {
      try path.ls().files.forEach { path in
        guard let decoder = decoders.first(where: { path.basename().hasSuffix($0.key) })?.value,
          let theme = decoder.decode(from: path) else { return }
              
        theme.path = path
        colorThemes.append(theme)
      }
    } catch {}
    
    if let themeURL = UserDefaults.standard.url(forKey: "colorTheme") {
      selectedTheme = colorThemes.first {
        $0.path?.url == themeURL
      }
    }
  }
}


// MARK: -

public protocol ColorThemeObserver {
  func colorThemeDidChanged(_ theme: ColorTheme)
}

public extension ColorThemeObserver {
  func colorThemeDidChanged(_ theme: ColorTheme) {}
}
