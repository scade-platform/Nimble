//
//  Settings.swift
//  NimbleCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

// MARK: - Setting

@propertyWrapper
final public class Setting<T: Codable> {
  let key: String
  let defaultValue: T

  public var observers = ObserverSet<SettingObserver>()

  public var wrappedValue: T {
    get { return Settings.shared.get(key) }
    set {
      Settings.shared.set(key, value: newValue)
      valueDidChange()
    }
  }

  public var projectedValue: Setting {
    return self
  }

  public init(_ key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
}

public protocol SettingObserver {
  func settingValueDidChange<T: Codable>(_ setting: Setting<T>)
}

protocol SettingProtocol: class {
  typealias DecodingContainer = KeyedDecodingContainer<RawCodingKey>
  typealias EncodingContainer = KeyedEncodingContainer<RawCodingKey>

  var key: String { get }
  var `default`: Any { get }

  func valueDidChange()

  static func encode(value: Any, to: inout EncodingContainer, forKey: RawCodingKey) throws
  static func decode(from: DecodingContainer, forKey: RawCodingKey) throws -> Any
}


struct SettingRef {
  let coder: SettingProtocol.Type
  weak var setting: SettingProtocol? = nil
  
  var defaultValue: Any { setting!.default }
  
  init(_ setting: SettingProtocol) {
    self.coder = type(of: setting)
    self.setting = setting
  }
}

fileprivate extension SettingProtocol {
  var ref: SettingRef { SettingRef(self) }
}

extension Setting: SettingProtocol {
  var `default`: Any {
    return self.defaultValue
  }

  func valueDidChange() {
    observers.notify {
      $0.settingValueDidChange(self)
    }
  }

  static func encode(value: Any, to container: inout EncodingContainer, forKey key: RawCodingKey) throws {
    try container.encode((value as! T), forKey: key)
  }
  
  static func decode(from container: DecodingContainer, forKey key: RawCodingKey) throws -> Any {
    let val = try container.decode(T.self, forKey: key)
    return val
  }
}

public extension Setting where T: Comparable {
  var isDefault: Bool { wrappedValue == defaultValue }
}



// MARK: - Global settings

public class Settings {
  struct Store {
    var data: [String: Any]
    weak var settings: Settings? = nil
    
    static var empty: Store { Store(data: [:]) }
  }
    
  private let loader: () -> Store

  private lazy var store: Store = loader()

  fileprivate var refs: [String: SettingRef] = [:]

  init(loader: @escaping () -> Store = { .empty }) {
    self.loader = loader
  }
      
  fileprivate func get<T: Codable>(_ key: String) -> T {
    assert(refs[key] != nil)
    let value = store.data[key] ?? refs[key]!.defaultValue
    return value as! T
  }
  
  fileprivate func set<T: Codable>(_ key: String, value: T) {
    assert(refs[key] != nil)
    store.data[key] = value
  }
    
  public var content: String {
    var store = Store(data: self.store.data, settings: self)
    
    refs.forEach {
      store.data[$0.key] = store.data[$0.key, default: $0.value.defaultValue]
    }
              
    do {
      let content = try YAMLEncoder().encode(store)
      
      guard let dictionary: [String: Any] = try Yams.load(yaml: content) as? [String: Any] else {
        return content
      }
      
      return dictionaryToString(dictionary)
    } catch {
      print("Error encoding settings file \(error)")
      return ""
    }
  }
  
  private func dictionaryToString(_ dictionary: [String: Any], level: Int = 0) -> String {
    var result = ""
    let sortedKeys = dictionary.keys.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
    for key in sortedKeys {
      if !result.isEmpty {
        result += "\n"
      }
      if let subDict = dictionary[key] as? [String: String] {
        result += "\(key):\n"
        result += dictionaryToString(subDict, level: level + 2)
      } else {
        for _ in 0..<level {
          result += " "
        }
        result += "\(key): \(optionalToString(optional: dictionary[key], defaultValue: ""))"
      }
    }
    return result
  }
  
 
  
  public func optionalToString(optional: Any?, defaultValue: String) -> String {
    switch optional {
    case let value? where value is NSNull: return defaultValue
    case let value?: return String(describing: value)
    case nil: return defaultValue
    }
  }

  
  public func add<T: Codable>(_ setting: Setting<T>) {
    assert(refs[setting.key] == nil)
    refs[setting.key] = setting.ref
  }

  public func reload() {
    self.store = loader()
    for (_, ref) in refs {
      ref.setting?.valueDidChange()
    }
  }
  
}


extension Settings {
  private static func defaultLoad() -> Store {
    guard let path = Settings.defaultPath,
          let content = try? String(contentsOf: path) else { return .empty }
    
    do {
      return try YAMLDecoder().decode(Store.self, from: content, userInfo: [.settings: shared])
    } catch {
      print("Error decoding settings file \(error)")
      return .empty
    }
  }
  
  public static let defaultPath: Path? = {
    guard let dir = try? (Path.applicationSupport/"Nimble"/"User").mkdir(.p) else {
      return nil
    }
    return dir/"settings.yml"
  }()
  
  public static var shared: Settings = Settings(loader: Settings.defaultLoad)
}



// MARK: - Settings Group

public protocol SettingsGroup {
  static var shared: Self { get }
}

public extension SettingsGroup {
  static func register() {
    let mirror = Mirror(reflecting: self.shared)
    for child in mirror.children {
      if let setting = child.value as? SettingProtocol {
        Settings.shared.refs[setting.key] = setting.ref
      }
    }
  }
}

// MARK: - Codable

public enum SettingCodingError: Error {
  case decodingError(String)
}

extension Settings.Store: Codable {
  init(from decoder: Decoder) throws {
    self.data = [:]
    self.settings = decoder.userInfo[.settings] as? Settings
    
    guard let defs = settings?.refs else {
      throw SettingCodingError.decodingError("Settings definitions not available")
    }
    
    let container = try decoder.container(keyedBy: RawCodingKey.self)
        
    container.allKeys.forEach {
      let key = $0.stringValue
      guard let coder = defs[key]?.coder else { return }
      
      do {
        self.data[key] = try coder.decode(from: container, forKey: $0)
      } catch {
        print("Error decoding settings: \(error)")
      }
    }
  }
  
  func encode(to encoder: Encoder) {
    let settings = self.settings ?? encoder.userInfo[.settings] as? Settings
    
    guard let defs = settings?.refs else {
      return
    }
        
    var container = encoder.container(keyedBy: RawCodingKey.self)
    
    data.forEach {
      guard let coder = defs[$0.key]?.coder else { return }
      
      do {
        let key = RawCodingKey(stringValue: $0.key)!
        try coder.encode(value: $0.value, to: &container, forKey: key)
      } catch {
        print("Error encoding settings: \(error)")
      }
    }
  }
}


// MARK: - CodingUserInfoKey

fileprivate extension CodingUserInfoKey {
  static let settings = CodingUserInfoKey(rawValue: "settings")!
}
