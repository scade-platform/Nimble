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
    providers.append(IconsProviderRef(value: provider))
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



// MARK: - Standard icons

public extension IconsManager {
  
  private static func icon(name: String) -> Icon {
    let isLight = NSView.systemInterfaceStlye == .light
    let iconPath = Bundle.main.resources/"Icons/\(name + (isLight ? "-light": "")).svg"
    return Icon(image: SVGImage(svg: iconPath.url))
  }
  
  enum Icons {
    public static var cancel = icon(name: "cancel")
    public static var circleFilled = icon(name: "circle-filled")
    public static var error = icon(name: "error")
    public static var file = icon(name: "file")
    public static var folder = icon(name: "folder")
    public static var folderOpened = icon(name: "folder-opened")
    public static var info = icon(name: "info")
    public static var rootFolder = icon(name: "root-folder")
    public static var rootFolderOpened = icon(name: "root-folder-opened")
    public static var run = icon(name: "run")
    public static var stop = icon(name: "stop")
    public static var trash = icon(name: "trash")
    public static var warning = icon(name: "warning")
  }
  
}
