//
//  IconProvider.swift
//  AFileIcon
//
//  Created by Grigory Markin on 15.03.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import AppKit
import NimbleCore

class FileIconsProvider: IconsProvider {
  let iconsPath: Path

  private lazy var fileIcons: FileIconsRegistry? =
    JSONDecoder.decode(from: iconsPath/"fileIcons.json")
    
  init(iconsPath: Path) {
    self.iconsPath = iconsPath
  }
  
  func icon<T>(for obj: T) -> Icon? {
    let path: Path?
    
    switch obj {
    case let file as File:
      path = file.path
    case let url as URL:
      path = Path(url: url)
    default:
      path = nil
    }
    
    if let path = path {
      return icon(for: path)
    }
    
    return nil
  }
  
  func icon(for path: Path) -> Icon? {
    if let fileName = fileIcons?.fileNameFor(name: path.basename()) {
      return icon(from: fileName)
    } else if let fileName = fileIcons?.fileNameFor(extension: path.extension) {
      return icon(from: fileName)
    } else {
      return nil
    }
  }
    
  func icon(from fileName: FileIconsRegistry.IconFileName) -> Icon? {
    let iconPath = iconsPath/fileName.dark
    return Icon(image: SVGImage(svg: iconPath.url))    
  }
}


struct FileIconsRegistry: Decodable {
  private struct Entry: Decodable {
    let name: String
    let light: Bool?
    let fileNames: [String]?
    let fileExtensions: [String]?
  }
  
  typealias IconFileName = (dark: String, light: String?)
  private typealias IconInfo = (name: String, light: Bool)
  
  private var names: [String: IconInfo] = [:]
  private var extensions: [String: IconInfo] = [:]
        
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    while !container.isAtEnd {
      let entry = try container.decode(Entry.self)
      
      let icon = IconInfo(name: entry.name, light: entry.light ?? false)
      
      if let fileNames = entry.fileNames {
        fileNames.forEach { names[$0] = icon }
      }
      
      if let fileExtensions = entry.fileExtensions {
        fileExtensions.forEach { extensions[$0] = icon }
      }
    }
  }
  
  private func fileNameFor(info: IconInfo) -> IconFileName? {
    return ("svg/\(info.name).svg", info.light ? "svg/\(info.name)_light.svg" : nil)
  }
  
  func fileNameFor(name: String) -> IconFileName? {
    guard let info = names[name] else { return nil }
    return fileNameFor(info: info)
  }
  
  func fileNameFor(extension: String) -> IconFileName? {
    guard let info = extensions[`extension`] else { return nil }
    return fileNameFor(info: info)
  }
}
