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
  public var settings: [Setting] = []
  
  public var global: GlobalSetting {
    for setting in settings {
      if case let .global(global) = setting {
        return global
      }
    }
    return GlobalSetting.default
  }

  public var scopes: [ScopeSetting] {
    var res: [ScopeSetting] = []
    for setting in settings {
      if case let .scope(scope) = setting {
        res.append(scope)
      }
    }
    return res
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
    public var scope: GrammarScope
    
    public var fontStyle: String?
    public var foreground: NSColor?
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: Setting.CodingKeys.self)
      
      // Decode scope
      self.name = try container.decode(String.self, forKey: .name)
      self.scope = try container.decode(GrammarScope.self, forKey: .scope)
      
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


// MARK: -

public final class ColorThemeManager {
  public var colorThemes: [ColorTheme] = []
  
  private let decoders: [String: ColorThemeDecoder.Type]  = [
    ".thTheme": PropertyListDecoder.self,
    ".tmTheme.yml": YAMLDecoder.self,
    ".thTheme.json": JSONDecoder.self
  ]
  
  public var currentTheme: ColorTheme!
  
  public static let shared = ColorThemeManager()
  
  public func load(from path: Path) {
    if path.isDirectory {
      _ = try? path.ls().files.forEach { load(from: $0) }
      
    } else if path.isFile {
      guard let decoder = decoders.first(where: { path.basename().hasSuffix($0.key) })?.value,
            let theme = decoder.decode(from: path) else { return }
      
      if path.basename().hasPrefix("Default-Dark") {
        self.currentTheme = theme
      }
      
      theme.path = path
      colorThemes.append(theme)
    }
  }
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


