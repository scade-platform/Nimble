//
//  WidgetFonts.swift
//  InterfaceBuilder
//
//  Created by Danil Kristalev on 17.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class WidgetFonts {
  public static var shared = WidgetFonts()
  
  lazy var systemFontFiles: [File] = {
    findFontFiles(by: "/System/Library/Fonts")
  }()
  
  
  lazy var localFontFiles: [File] = {
    findFontFiles(by: "/Library/Fonts")
  }()
  
  lazy var userFontFiles: [File] = {
    findFontFiles(by: "~/Library/Fonts")
  }()
  
  lazy var supportedFontFamilies: [String] = {
    var result = fontFamilies(from: self.systemFontFiles)
    result.append(contentsOf: fontFamilies(from: self.localFontFiles))
    result.append(contentsOf: fontFamilies(from: self.userFontFiles))
    return result.sorted()
  }()
  
  private func fontFamilies(from files: [File]) -> [String] {
    var setFamilies: Set<String> = []
    for file in files {
      guard !setFamilies.contains(where: {file.name.hasPrefix($0)}) else { continue }
      let fd = CTFontManagerCreateFontDescriptorsFromURL(file.url as CFURL) as! [CTFontDescriptor]
      let theCTFont = CTFontCreateWithFontDescriptor(fd[0], 12.0, nil)
      let nsFont: NSFont = theCTFont
      if let familyName = nsFont.familyName, !familyName.hasPrefix(".") {
         setFamilies.insert(familyName)
      }
    }
    return Array(setFamilies)
  }
  
  private func findFontFiles(by path: String) -> [File] {
    guard let systemFontFolder = Folder(path: path) else {
      return []
    }
    var result = [File]()
    
    for file in (try? systemFontFolder.files()) ?? [] {
      if file.path.extension == "ttf" || file.path.extension == "otf" {
        result.append(file)
      }
    }
    
    for subfolder in (try? systemFontFolder.subfolders()) ?? [] {
      result.append(contentsOf: findFontFiles(by: subfolder.path.string))
    }
    
    return result
  }
}
