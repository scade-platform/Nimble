//
//  AppDelegate.swift
//  Nimble
//
//  Created by Grigory Markin on 03.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  let documentController = NimbleController()
  
  @IBOutlet var openRecentDocumentMenu: NSMenu?
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    // Replace the default delegate installed by the NSDocumentController
    // The default one shows all recent documents without filtering etc.
    openRecentDocumentMenu?.delegate = self
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    
  }
  
  func openHandler(doc: NSDocument?, alreadyOpened: Bool, error: Error?) -> Void {
    ///TODO: implement
  }
  
  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    guard let path = Path(filename) else { return true }
    
    if path.url.typeIdentifierConforms(to: ProjectDocument.docType) {
      documentController.openProject(withContentsOf: path.url,
                                     completionHandler: openHandler)
              
    } else {
      documentController.openDocument(withContentsOf: path.url,
                                      display: true,
                                      completionHandler: openHandler)
    }
        
    return true
  }
  
  
//  func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
//    //return true
//  }
  
}


extension AppDelegate : NSMenuDelegate {
  func menuNeedsUpdate(_ menu: NSMenu) {
    documentController.updateOpenRecentMenu(menu)
  }
}
