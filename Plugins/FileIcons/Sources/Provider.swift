//
//  IconProvider.swift
//  AFileIcon
//
//  Created by Grigory Markin on 15.03.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import AppKit
import NimbleCore

fileprivate typealias IconInfo = (name: String, light: Bool)

class FileIconsProvider: IconsProvider {
  let iconsPath: Path

  private lazy var fileIcons: FileIconsRegistry? =
    JSONDecoder.decode(from: iconsPath/"fileIcons.json")
  
  private lazy var folderIcons: FolderIconsRegistry? =
    JSONDecoder.decode(from: iconsPath/"folderIcons.json")
  
  init(iconsPath: Path) {
    self.iconsPath = iconsPath
  }
  
  func icon<T>(for obj: T) -> Icon? {
    let path: Path?
    
    switch obj {
//    case let folder as Folder:
//      return icon(for: folder)
      
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
  
  private func icon(for path: Path) -> Icon? {
    if let iconInfo = fileIcons?.names[path.basename()] {
      return icon(from: iconInfo)
    } else if let iconInfo = fileIcons?.extensions[path.extension] {
      return icon(from: iconInfo)
    } else {
      return nil
    }
  }
   
  private func icon(for folder: Folder) -> Icon? {
    guard let iconInfo = folderIcons?.names[folder.path.basename().lowercased()] else { return nil }
    return icon(from: iconInfo)
  }
  
  private func icon(from iconInfo: IconInfo) -> Icon? {
    let filePath: String
    if iconInfo.light, let themeLight = ThemeManager.shared.currentTheme?.light, themeLight {
      filePath = "svg/\(iconInfo.name)_light.svg"
    } else {
      filePath = "svg/\(iconInfo.name).svg"
    }
    let iconPath = iconsPath/filePath
    return Icon(image: SVGImage(svg: iconPath.url))    
  }
}


struct FileIconsRegistry: Decodable {
  private struct RawEntry: Decodable {
    let name: String
    let light: Bool?
    let fileNames: [String]?
    let fileExtensions: [String]?
  }
      
  fileprivate var names: [String: IconInfo] = [:]
  fileprivate var extensions: [String: IconInfo] = [:]
        
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    while !container.isAtEnd {
      let entry = try container.decode(RawEntry.self)
      
      let icon = IconInfo(name: entry.name, light: entry.light ?? false)
      
      if let fileNames = entry.fileNames {
        fileNames.forEach { names[$0] = icon }
      }
      
      if let fileExtensions = entry.fileExtensions {
        fileExtensions.forEach { extensions[$0] = icon }
      }
    }
  }
}


struct FolderIconsRegistry: Decodable {
  private struct RawEntry: Decodable {
    let name: String
    let light: Bool?
    let folderNames: [String]?
  }
      
  fileprivate var names: [String: IconInfo] = [:]
        
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    while !container.isAtEnd {
      let entry = try container.decode(RawEntry.self)
      
      let icon = IconInfo(name: entry.name, light: entry.light ?? false)
      
      if let folderNames = entry.folderNames {
        folderNames.forEach { names[$0] = icon }
      }
  
    }
  }
}
