//
//  EditorTab.swift
//  Nimble
//
//  Created by Danil Kristalev on 16.06.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

struct EditorTabItem: Hashable {
  let title: String
  let iconImage: NSImage?
  let path: String

  init(document: Document) {
    self.title = document.title
    self.iconImage = document.icon?.image
    self.path = document.path?.string ?? ""
  }

  init(title: String, icon: NSImage? = nil) {
    self.title = title
    self.iconImage = icon
    self.path = ""
  }

  static var empty = EditorTabItem(title: "")
}


class EditorTab: NSCollectionViewItem {
  static let reuseIdentifier = NSUserInterfaceItemIdentifier("EditorTabReuseIdentifier")

  @IBOutlet private weak var closeButton: HiddenButton!
  @IBOutlet private weak var titleLabel: NSTextField!
  @IBOutlet private weak var backgroundView: NSView!
  @IBOutlet private weak var tabIconView: NSImageView!

  var item: EditorTabItem = .empty {
    didSet {
      guard isViewLoaded else { return }
      titleLabel.stringValue = item.title
      if let image = item.iconImage {
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

  static func calculateSize(for item: EditorTabItem) -> NSSize {
    let height = 30.0
    let closeButtonWidth = 25.0
    let indent = 5.0
    let indentRight = 30.0
    let imageWidth = 20.0
    let lineWidth = 1.0
    let moreSpace = 10.0

    let titleAttrinbutedString = NSString(string: item.title)
    let titleSize = titleAttrinbutedString.size(withAttributes: [ .font: NSFont.systemFont(ofSize: 13)])

    var resultWidth: Double = 0.0
    resultWidth = indent + closeButtonWidth + indent
    resultWidth += item.iconImage != nil ? imageWidth : 0.0
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
