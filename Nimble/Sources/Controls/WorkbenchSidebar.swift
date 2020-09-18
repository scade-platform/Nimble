//
//  WorkbenchSidebar.swift
//  Nimble
//
//  Created by Grigory Markin on 05.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

public class WorkbenchSidebar: XibView {
  @IBOutlet var stackView: NSStackView? = nil
  
  @IBOutlet var tabView: NSTabView? = nil
  
  private var selectedViewIndex: Int = 0
  
  public var showButtonsBar: Bool = true {
    didSet {
      guard let heightCnstr = stackView?.constraints.first(where: { $0.identifier == .some("buttonsBarHeight") }) else {
        return
      }

      heightCnstr.constant = showButtonsBar ? 28 : 0
    }
  }

  public var showTabIcon: Bool = true

  public var showTabTitle: Bool = false


  public override func awakeFromNib() {
    super.awakeFromNib()
    
    assert(stackView != nil && tabView != nil &&
      stackView!.arrangedSubviews.count == tabView!.tabViewItems.count)
    
    for (i, view) in stackView!.arrangedSubviews.enumerated() {
      guard let btn = view as? NSButton else { continue }
      
      btn.state = (i == selectedViewIndex) ? .on : .off
      btn.target = self
      btn.action = #selector(onStackButtonPressed(_:))
    }
    
    if tabView!.tabViewItems.count > 0 {
      tabView!.selectTabViewItem(at: selectedViewIndex)
    }
  }
  
  
  public func selectView(at: Int) -> Void {
    if at == selectedViewIndex { return }
    
    assert(tabView?.tabViewItems.indices.contains(at) ?? false)
    assert(stackView?.arrangedSubviews.indices.contains(at) ?? false)
    
    guard let _activeButton = button(at: selectedViewIndex) else { return }
    guard let _selectedButton = button(at: at) else { return }
    
    _activeButton.state = .off
    _selectedButton.state = .on
    
    tabView!.selectTabViewItem(at: at)
    
    selectedViewIndex = at
  }
  
  public func appendView(_ view: NSView, title: String, icon: NSImage?) -> Void {
    assert(stackView != nil && tabView != nil)
    
    let button = NSButton(frame: NSRect.zero)
    
    if showTabIcon {
      button.image = icon
      button.title = ""
    }

    if showTabTitle {
      button.title = title
    }
    
    button.target = self
    button.action = #selector(onStackButtonPressed(_:))
    button.bezelStyle = .shadowlessSquare
    button.isBordered = false
    button.setButtonType(.toggle)

    //button.contentTintColor = .white
    //stackView!.addArrangedSubview(button)

    stackView!.addView(button, in: .leading)

    let tabViewItem = NSTabViewItem(identifier: nil)
    tabViewItem.view = view
    
    tabView!.addTabViewItem(tabViewItem)
    selectView(at: stackView!.arrangedSubviews.count - 1)
  }

  private func button(at: Int) -> NSButton? {
    guard let _stackView = stackView else { return nil }
    if _stackView.arrangedSubviews.indices.contains(at) {
      return _stackView.arrangedSubviews[at] as? NSButton
    } else {
      return nil
    }
  }
  
  @objc private func onStackButtonPressed(_ button: NSButton) -> Void {
    guard let index = self.stackView?.arrangedSubviews.firstIndex(of: button) else { return }
    // Move state back, as by pressing the button, state was changed automatically
    button.setNextState()
    selectView(at: index)
  }


}






