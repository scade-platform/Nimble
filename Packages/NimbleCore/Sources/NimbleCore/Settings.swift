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
public class Setting<T: Codable> {
  let key: String
  let defaultValue: T
  
  fileprivate var ref: SettingRef { SettingRef(self) }
      
  public var wrappedValue: T {
    get { return Settings.shared.get(key) }
    set { Settings.shared.set(key, value: newValue) }
  }
  
  public var projectedValue: Setting {
    return self
  }
    
  public init(_ key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
}

public enum SettingError: Error {
  case decodingError(String)
}


protocol SettingProtocol: class {
  var `default`: Any { get }
  
  static func encode(value: Any, to container: inout KeyedEncodingContainer<RawCodingKey>, forKey key: RawCodingKey) throws
  static func decode(from container: KeyedDecodingContainer<RawCodingKey>, forKey key: RawCodingKey) throws -> Any
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


extension Setting: SettingProtocol {
  var `default`: Any {
    return self.defaultValue
  }
  
  static func encode(value: Any,
                     to container: inout KeyedEncodingContainer<RawCodingKey>,
                     forKey key: RawCodingKey) throws {
    
    try container.encode((value as! T), forKey: key)
  }
  
  static func decode(from container: KeyedDecodingContainer<RawCodingKey>,
                     forKey key: RawCodingKey) throws -> Any {
    
    let val = try container.decode(T.self, forKey: key)
    return val
  }
}

public extension Setting where T: Comparable {
  var isDefault: Bool { wrappedValue == defaultValue }
}



// MARK: - Settings

public class Settings {
  struct Store {
    fileprivate var data: [String: Any]
    fileprivate weak var settings: Settings? = nil
    
    static var empty: Store { Store(data: [:]) }
  }
    
  private let loader: () -> Store
  
  private var refs: [String: SettingRef] = [:]
  
//  private var groups: [SettingsGroup] = []
  
  private lazy var store: Store = loader()
  
  
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
      return try YAMLEncoder().encode(store)
    } catch {
      print("Error encoding settings file \(error)")
      return ""
    }
  }
  
  public func add<T: Codable>(_ setting: Setting<T>) {
    assert(refs[setting.key] == nil)
    refs[setting.key] = setting.ref
  }
  
//  public func add(group: SettingsGroup) {
//
//  }
  
  public func reload() {
    self.store = loader()
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


//public class SettingsGroup {
//  fileprivate weak var settings: Settings? = nil
//
//  public let key: String
//  public let title: String
//
//  public init(key: String, title: String) {
//    self.key = key
//    self.title = title
//  }
//}


// MARK: - Codable

extension Settings.Store: Codable {
  init(from decoder: Decoder) throws {
    self.data = [:]
    self.settings = decoder.userInfo[.settings] as? Settings
    
    guard let defs = settings?.refs else {
      throw SettingError.decodingError("Settings definitions not available")
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
