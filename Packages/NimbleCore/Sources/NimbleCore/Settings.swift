//
//  Settings.swift
//  NimbleCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

//MARK: - Glogal settings

///Centralized storage of settings
public final class Settings {
  
  ///Function to deserialize settings from the storing place
  private let loader: () -> Storage
  
  ///Instance of `Storage` loaded by loader
  private lazy var storage: Storage = loader()

  ///Storage of `RuntimeData`
  private lazy var runtime: RuntimeStorage = .clear
  
  fileprivate init(loader: @escaping () -> Storage = { .empty }) {
    self.loader = loader
  }
  
  //MARK: - Instance of Settings
  
  public static var shared: Settings = Settings(loader: Settings.defaultLoad)
  
  //By default settings storing as YAML file
  private static func defaultLoad() -> Storage {
    guard let path = Settings.defaultPath,
          let content = try? String(contentsOf: path) else { return .empty }
    
    do {
      return try YAMLDecoder().decode(Storage.self, from: content, userInfo: [.settings: shared])
    } catch {
      print("Error decoding settings file \(error)")
      return .empty
    }
  }
  
  ///Default path to settings file
  public static let defaultPath: Path? = {
    guard let dir = try? (Path.applicationSupport/"Nimble"/"User").mkdir(.p) else {
      return nil
    }
    return dir/"settings.yml"
  }()
  
  public func reload() {
    self.storage = loader()
    
    for key in runtime.definedSettingKeys {
      runtime[key]!.notifyObservers()
    }
  }
  
  //MARK: - Access to settings
  
  ///Check if setting by given key is defined
  fileprivate func isDefined(_ key: String) -> Bool {
    runtime.definedSettingKeys.contains(key)
  }
  
  fileprivate func get<T: Codable>(_ key: String) -> T? {
    assert(isDefined(key))

    if let value = runtime[key]?.data {
      return value as? T
    }

    if let value = storage.data[key] {
      return value as? T
    }
    
    if let value = runtime[key]?.defaultValueProvider() {
      return value as? T
    }
    
    return nil
  }
  
  fileprivate func set<T: Codable>(_ key: String, value: T) {
    assert(isDefined(key))
    
    runtime[key]!.data = value
    runtime[key]!.notifyObservers()
  }
  
  fileprivate func defaultValue<T: Codable>(for key: String) -> T {
    assert(isDefined(key))
    
    return runtime[key]!.defaultValueProvider() as! T
  }
  
  fileprivate func add(observer: SettingObserver, for key: String) {
    assert(isDefined(key))
    
    runtime[key]!.observers.add(observer: observer)
  }
  
  fileprivate func remove(observer: SettingObserver, for key: String) {
    assert(isDefined(key))
    
    runtime[key]!.observers.remove(observer: observer)
  }
  
  
  //MARK: - Setting register
  
  public func register<S: SettingDefinitionProtocol>(_ settingDefenition: S) where S: SettingCoder {
    //Define every setting only once
    assert(!isDefined(settingDefenition.key))
    runtime[settingDefenition.key] = TypedRuntimeData(settingDefenition)
  }
  
  
  // MARK: - Settings content
  
  public var content: String {
    var workingCopy = self.storage
    
    //Set default value for registered in runtime but not stored setting
    runtime.definedSettingKeys.forEach {
      workingCopy.data[$0] = workingCopy.data[$0, default: self.runtime[$0]!.defaultValueProvider()]
    }
    
    do {
      let content = try YAMLEncoder().encode(workingCopy)
      
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
  
  private func optionalToString(optional: Any?, defaultValue: String) -> String {
    switch optional {
    case let value? where value is NSNull: return defaultValue
    case let value?: return String(describing: value)
    case nil: return defaultValue
    }
  }
  
}

//MARK: - Storage

fileprivate extension Settings {
  ///Inner storage which `Settings` uses to store, serealize and deserealize the setting values
  struct Storage: Codable {
    var data: [String: Any]
    
    weak var settings: Settings? = nil
    
    static var empty: Storage { Storage() }
    
    init(data: [String: Any] = [:]) {
      self.data = data
    }
    
    init(from decoder: Decoder) throws {
      self.data = [:]
      self.settings = decoder.userInfo[.settings] as? Settings
      
      guard let runtime = settings?.runtime else {
        throw SettingCodingError.decodingError("Settings definitions not available")
      }
      
      let container = try decoder.container(keyedBy: RawCodingKey.self)
          
      container.allKeys.forEach {
        let key = $0.stringValue
        guard let coder = runtime[key]?.coder else {
          print("Coder for setting by key \"\(key)\" is not available")
          return
        }
        
        do {
          self.data[key] = try coder.decode(from: container, forKey: $0)
        } catch {
          print("Error decoding settings: \(error)")
        }
      }
    }
    
    func encode(to encoder: Encoder) {
      let settings = self.settings ?? encoder.userInfo[.settings] as? Settings
      
      guard let runtime = settings?.runtime else {
        return
      }
          
      var container = encoder.container(keyedBy: RawCodingKey.self)
      
      data.forEach {
        guard let coder = runtime[$0.key]?.coder else {
          print("Coder for setting by key \"\($0.key)\" is not available")
          return
        }
        
        do {
          let key = RawCodingKey(stringValue: $0.key)!
          try coder.encode(value: $0.value, to: &container, forKey: key)
        } catch {
          print("Error encoding settings: \(error)")
        }
      }
    }
  }
  
  ///Inner storage which `Settings` uses to store runtime data
  struct RuntimeStorage {
    
    static var clear: RuntimeStorage { RuntimeStorage() }
    
    private var data: [String: RuntimeData] = [:]
    
    var definedSettingKeys: Set<String> {
      Set(data.keys)
    }
    
    subscript(_ key: String) -> RuntimeData? {
      get {
        data[key]
      }
      set {
        data[key] = newValue
      }
    }
  }
  
  struct TypedRuntimeData<T: Codable>: RuntimeData {
    let key: String
    
    let typedDefaultValueProvider: () -> T
    let coder: SettingCoder.Type
    
    var typedData: T? = nil
    var observers: ObserverSet<SettingObserver>
    
    var data: Any? {
      get { typedData }
      set {
        typedData = newValue as? T
      }
    }
    
    var defaultValueProvider: () -> Any {
      typedDefaultValueProvider
    }
    
    init<S: SettingDefinitionProtocol>(_ settingDefinition: S) where S: SettingCoder, T == S.ValueType{
      self.key = settingDefinition.key
      self.typedDefaultValueProvider = settingDefinition.defaultValueProvider
      self.coder = S.self
      self.observers = ObserverSet()
    }
    
    func notifyObservers() {
      let setting = Setting<T>(key)
      self.observers.notify{$0.settingValueDidChange(setting)}
    }
  }
  
  enum SettingCodingError: Error {
    case decodingError(String)
  }
}

fileprivate protocol RuntimeData {
  var key: String { get }
  var defaultValueProvider: () -> Any { get }
  var coder: SettingCoder.Type { get }
  
  var data: Any? { get set }
  var observers: ObserverSet<SettingObserver> { get set }
  
  func notifyObservers()
}

// MARK: - CodingUserInfoKey

fileprivate extension CodingUserInfoKey {
  static let settings = CodingUserInfoKey(rawValue: "settings")!
}

//MARK: - SettingCoder

public protocol SettingCoder {
  typealias DecodingContainer = KeyedDecodingContainer<RawCodingKey>
  typealias EncodingContainer = KeyedEncodingContainer<RawCodingKey>
  
  static func encode(value: Any, to container: inout EncodingContainer, forKey key: RawCodingKey) throws
  static func decode(from container: DecodingContainer, forKey key: RawCodingKey) throws -> Any
}

//MARK: - SettingDefinitionProtocol

public protocol SettingDefinitionProtocol {
  associatedtype ValueType: Codable
  typealias DefaultValueProvider = () -> ValueType

  var defaultValueProvider: DefaultValueProvider { get }
  var key: String { get }
}


public extension SettingDefinitionProtocol where Self: SettingCoder {
  
  static func encode(value: Any, to container: inout EncodingContainer, forKey key: RawCodingKey) throws {
    try container.encode((value as! ValueType), forKey: key)
  }
  
  static func decode(from container: DecodingContainer, forKey key: RawCodingKey) throws -> Any {
    let val = try container.decode(ValueType.self, forKey: key)
    return val
  }
}


//MARK: - SettingCommonProtocol
public protocol SettingCommonProtocol {
  var key: String { get }
}

public extension SettingCommonProtocol {
  func add(observer: SettingObserver) {
    Settings.shared.add(observer: observer, for: key)
  }
  
  func remove(observer: SettingObserver) {
    Settings.shared.remove(observer: observer, for: key)
  }
  
  func add<C: Collection>(observers: C) where C.Element == SettingObserver {
    for observer in observers {
      add(observer: observer)
    }
  }
}


//MARK: - SettingDefinition

@propertyWrapper
public struct SettingDefinition<T: Codable> : SettingDefinitionProtocol {
  public typealias DefaultValueProvider = () -> T
  
  public let defaultValueProvider: DefaultValueProvider
  public let key: String
  
  public var wrappedValue: T {
    get {
      Settings.shared.get(key)!
    }
    set {
      Settings.shared.set(key, value: newValue)
    }
  }
  
  public var projectedValue: SettingDefinition {
    return self
  }
  
  public lazy var defaultValue = defaultValueProvider()
  
  public init(_ key: String, defaultValueProvider: @escaping DefaultValueProvider) {
    self.key = key
    self.defaultValueProvider = defaultValueProvider
    Settings.shared.register(self)
  }
  
  public init(_ key: String, defaultValue: @escaping @autoclosure DefaultValueProvider) {
    self.key = key
    self.defaultValueProvider = defaultValue
    Settings.shared.register(self)
  }
}

extension SettingDefinition: SettingCoder {}
extension SettingDefinition: SettingCommonProtocol {}


//MARK: - Setting

@propertyWrapper
public struct Setting<T: Codable> {
  public let key: String
  
  public var wrappedValue: T {
    get {
      Settings.shared.get(key)!
    }
    set {
      Settings.shared.set(key, value: newValue)
    }
  }
  
  public lazy var defaultValue: T = {
    Settings.shared.defaultValue(for: key)!
  }()
  
  public var projectedValue: Setting {
    return self
  }
  
  public init(_ key: String) {
    self.key = key
  }
}

extension Setting: SettingCommonProtocol {}

//MARK: - SettingObserver

public protocol SettingObserver {
  func settingValueDidChange<T: Codable>(_ setting: Setting<T>)
}

// MARK: - Settings Group

public protocol SettingsGroup {
  static var shared: Self { get }
}

public extension SettingsGroup {
  static func register() {
    let _ = self.shared
  }
}
