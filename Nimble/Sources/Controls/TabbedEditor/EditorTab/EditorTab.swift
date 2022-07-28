//
//  EditorTab.swift
//  Nimble
//
//  Created by Danil Kristalev on 16.06.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class EditorTab: NSCollectionViewItem {
  static let reuseIdentifier = NSUserInterfaceItemIdentifier("EditorTabReuseIdentifier")

  @IBOutlet private weak var closeButton: HiddenButton!
  @IBOutlet private weak var titleLabel: NSTextField!
  @IBOutlet private weak var backgroundView: NSView!
  @IBOutlet private weak var tabIconView: NSImageView!
  @IBOutlet private weak var separatorView: NSView!

  override var isSelected: Bool {
    didSet {
      updateSelectionHighlighting()
    }
  }

  override var highlightState: NSCollectionViewItem.HighlightState {
    didSet {
      updateSelectionHighlighting()
    }
  }

  private var showAsHighlighted: Bool {
    (highlightState == .forSelection) ||
    (isSelected && highlightState != .forDeselection)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true
    // TODO: Hide close button
  }

  func present(item: EditorTabItem) {
    guard isViewLoaded else { return }

    titleLabel.stringValue = item.title
    if let image = item.iconImage {
      tabIconView.image = image
    } else {
      tabIconView.isHidden = true
    }
  }

  private func updateSelectionHighlighting() {
    guard isViewLoaded else { return }
    separatorView.isHidden = showAsHighlighted
    view.layer?.backgroundColor = showAsHighlighted ? NSColor.selectedControlColor.cgColor : .clear
  }

  // TODO: Close tab handler

  static func calculateSize(for item: EditorTabItem) -> NSSize {
    let height = 30.0
    let closeButtonWidth = 25.0
    let indent = 5.0
    let indentRight = 10.0
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
