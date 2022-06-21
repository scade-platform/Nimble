//
//  EditorTab.swift
//  Nimble
//
//  Created by Danil Kristalev on 16.06.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

struct EditorTabModel {
  let title: String
  let icon: NSImage?

  init(document: Document) {
    self.title = document.title
    self.icon = document.icon?.image
  }

  init(title: String, icon: NSImage? = nil) {
    self.title = title
    self.icon = icon
  }

  static var empty = EditorTabModel(title: "")
}

class EditorTab: NSCollectionViewItem {
  static var itemId: NSUserInterfaceItemIdentifier {
    NSUserInterfaceItemIdentifier("EditorTab")
  }

  @IBOutlet private weak var closeButton: HiddenButton!
  @IBOutlet private weak var titleLabel: NSTextField!
  @IBOutlet private weak var backgroundView: NSView!
  @IBOutlet private weak var tabIconView: NSImageView!

  var model: EditorTabModel = .empty {
    didSet {
      guard isViewLoaded else { return }
      titleLabel.stringValue = model.title
      if let image = model.icon {
        tabIconView.image = image
      } else {
        tabIconView.isHidden = true
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true
    // TODO: Hide close button
  }

  // TODO: Close tab handler

  static func calculateSize(for model: EditorTabModel) -> NSSize {
    let height = 30.0
    let closeButtonWidth = 25.0
    let indent = 5.0
    let indentRight = 30.0
    let imageWidth = 20.0
    let lineWidth = 1.0
    let moreSpace = 10.0

    let titleAttrinbutedString = NSString(string: model.title)
    let titleSize = titleAttrinbutedString.size(withAttributes: [ .font: NSFont.systemFont(ofSize: 13)])

    var resultWidth: Double = 0.0
    resultWidth = indent + closeButtonWidth + indent
    resultWidth += model.icon != nil ? imageWidth : 0.0
    resultWidth += titleSize.width.rounded(.up)
    resultWidth += indentRight
    resultWidth += lineWidth + indent
    resultWidth += moreSpace

    return NSSize(width: resultWidth, height: height)
  }

}

class HiddenButton: NSButton {
  private var trackingArea: NSTrackingArea? = nil

  override func updateTrackingAreas() {
    if let ta = trackingArea {
      self.removeTrackingArea(ta)
    }

    let opts: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, ]
    trackingArea = NSTrackingArea(rect: self.bounds, options: opts, owner: self)

    self.addTrackingArea(trackingArea!)
    super.updateTrackingAreas()
  }

  override func mouseEntered(with theEvent: NSEvent) {
    self.isBordered = true
  }

  override func mouseExited(with event: NSEvent) {
    self.isBordered = false
  }
}
