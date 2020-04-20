//
//  Icon.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//

import AppKit


// MARK: - Icon

public struct Icon {
  private let _image: NSImage
  private let _imageLight: NSImage?

  public var tint: IconTint? = nil

  public var image: NSImage {
    return NSImage(size: self._image.size, flipped: true) {
      self.image(for: Theme.Style.system).draw(in: $0)
      if let tint = self.tint {
        tint.color.set()
        $0.fill(using: .sourceAtop);
      }
      return true
    }
  }

  public func image(for style: Theme.Style) -> NSImage {
    switch style {
    case .light:
      return _imageLight ?? _image
    default:
      return _image
    }
  }

  public init(image: NSImage, light: NSImage? = nil, tint: IconTint? = nil) {
    self._image = image
    self._imageLight = light

    self.tint = tint
  }

  public init?(url: URL, light: URL? = nil, tint: IconTint? = nil) {
    var image: NSImage

    if url.pathExtension.hasSuffix("svg") {
      image = SVGImage(svg: url)
    } else if let img = NSImage(contentsOf: url) {
      image = img
    } else {
      return nil
    }

    var imageLight: NSImage? = nil
    if let urlLight = light {
      if urlLight.pathExtension.hasSuffix("svg") {
        imageLight = SVGImage(svg: urlLight)
      } else {
        imageLight = NSImage(contentsOf: urlLight)
      }
    }

    self.init(image: image, light: imageLight, tint: tint)
  }

}


public struct IconTint {
  private enum Color {
    case color(NSColor)
    case asset(String, Bundle?, NSColor)

    var nsColor: NSColor {
      switch self {

      case .color(let color):
        return color

      case .asset(let name, let bundle, let `default`):
        if let bundle = bundle {
          return NSColor(named: name, bundle: bundle) ?? `default`
        } else {
          return NSColor(named: name) ?? `default`
        }
      }
    }
  }

  private let _color: Color
  private let _colorLight: Color?

  public var color: NSColor {
    return color(for: Theme.Style.system)
  }

  public func color(for style: Theme.Style) -> NSColor {
    switch style {
    case .light:
      return self._colorLight?.nsColor ?? self._color.nsColor
    default:
      return self._color.nsColor
    }
  }

  public init(color: NSColor, light: NSColor? = nil) {
    self._color = .color(color)
    if let colorLight = light {
      self._colorLight = .color(colorLight)
    } else {
      self._colorLight = nil
    }
  }

  public init?(colorCode: String, light: String? = nil) {
    guard let color = NSColor(colorCode: colorCode) else { return nil }

    var colorLight: NSColor? = nil
    if let colorCodeLight = light {
      colorLight = NSColor(colorCode: colorCodeLight)
    }

    self.init(color: color, light: colorLight)
  }

  public init(named: String, bundle: Bundle? = nil, `default`: NSColor = .clear) {
    self._color = .asset(named, bundle, `default`)
    self._colorLight = nil
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
  private static func icon(name: String, tint: IconTint? = nil) -> Icon {
    let image = SVGImage(svg: Bundle.main.resources/"Icons/\(name).svg")
    let urlLight = Bundle.main.resources/"Icons/\(name)-light.svg"

    if urlLight.exists {
      return Icon(image: image, light: SVGImage(svg: urlLight))
    } else {
      return Icon(image: image, tint: tint)
    }
  }

  private static let buttonIconColor = IconTint(named: "ButtonIconColor")

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

    public static var run = icon(name: "run", tint: buttonIconColor)
    public static var stop = icon(name: "stop", tint: buttonIconColor)

    public static var trash = icon(name: "trash")
    public static var warning = icon(name: "warning")
    
    public static var separator = icon(name: "separator")
  }
  
}
