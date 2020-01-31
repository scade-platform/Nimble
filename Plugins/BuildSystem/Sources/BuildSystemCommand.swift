//
//  BuildSystemCommand.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 31/01/2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

class BuildCommandDelegate: CommandDelegate {
  func menuItemPath(for command: Command) -> String? {
    return "Tools"
  }
  
  func menuItem(for command: Command) -> NSMenuItem? {
    let buildMenuItem = NSMenuItem(title: "Build", action: #selector(executeBuild(_:)), keyEquivalent: "b")
    buildMenuItem.keyEquivalentModifierMask = .command
    buildMenuItem.target = self
    return buildMenuItem
  }
  
  func toolbarItem(for command: Command) -> NSToolbarItem? {
    let identifier = NSToolbarItem.Identifier("BuildCommand")
    let item = NSToolbarItem(itemIdentifier: identifier)
    item.label = "Build"
    item.paletteLabel = "Build"
    let image = Bundle(for: BuildCommandDelegate.self).image(forResource: "run")?.imageWithTint(.darkGray)
    let button = NSButton()
    button.cell = ButtonCell()
    button.image = image
    button.action = #selector(executeBuild(_:))
    button.target = self
    let width: CGFloat = 38.0
    let height: CGFloat = 28.0
    button.widthAnchor.constraint(equalToConstant: width).isActive = true
    button.heightAnchor.constraint(equalToConstant: height).isActive = true
    button.title = ""
    button.imageScaling = .scaleProportionallyDown
    button.bezelStyle = .texturedRounded
    button.focusRingType = .none
    item.view = button
    return item
  }
  
  @objc func executeBuild(_ item: NSMenuItem?) {
    //Workbench for active window
    guard let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench else { return }
    BuildSystemsManager.shared.activeBuildSystem?.run(in: currentWorkbench)
  }
}


class ButtonCell: NSButtonCell {
  
  override func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {
    super.drawImage(image, withFrame: frame.insetBy(dx: 0, dy: 2), in: controlView)
  }
  
}
