//
//  IconsController.swift
//  Scade
//
//  Created by Danil Kristalev on 25.08.2021.
//  Copyright © 2021 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class IconController: IconsProvider {
  func icon<T>(for obj: T) -> Icon? {
    switch obj {
    case is File, is Document:
      return IconsManager.Icons.file
      
    case let folder as Folder:
      if folder.isRoot {
        return folder.isOpened ?  IconsManager.Icons.rootFolderOpened : IconsManager.Icons.rootFolder
      } else {
        return folder.isOpened ?  IconsManager.Icons.folderOpened : IconsManager.Icons.folder
      }
      
    default:
      return nil
    }
  }
}
