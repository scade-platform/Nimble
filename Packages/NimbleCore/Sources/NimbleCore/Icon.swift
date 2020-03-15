//
//  Icon.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//

import AppKit


// MARK: - Icon

public struct Icon {
  public let image: NSImage
  
  public init(image: NSImage) {
    self.image = image
  }
}


// MARK: - IconsManager

public class IconsManager {
  private struct IconsProviderRef {
    weak var value: IconsProvider!
  }
  
  private var providers: [IconsProviderRef] = []
  
  private init() {}
  
  public func register(provider: IconsProvider) {
    providers.insert(IconsProviderRef(value: provider), at: 0)
  }
  
  public func icon<T>(for obj: T) -> Icon? {
    for p in providers {
      if let icon = p.value.icon(for: obj) {
        return icon
      }
    }
    return nil
  }
}

public extension IconsManager {
  static let shared = IconsManager()
}


// MARK: - IconsProvider

public protocol IconsProvider: class {
  func icon<T>(for obj: T) -> Icon?
}


// MARK: - Extensions

public extension FileSystemElement {
  var icon: Icon? { IconsManager.shared.icon(for: self) }
}

public extension Document {
  var icon: Icon? {
    var icon: Icon? = nil
    if let url = fileURL {
      icon = IconsManager.shared.icon(for: url)
    }
    return icon ?? IconsManager.shared.icon(for: self)
  }
}
