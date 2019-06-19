//
//  InterfaceBuilderController.swift
//  InterfaceBuilder
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

class InterfaceBuilderController: NSViewController {
  @IBOutlet
  weak var pageView: PageView? = nil
  
  weak var doc: PageDocument? = nil {
    didSet {
      //loadPage()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    if let svgSize = doc?.getSvgSize() {
      if let view = pageView {
        for c in view.constraints {
          switch c.identifier {
          case .some("width"):
            c.constant = svgSize.width
            
          case .some("height"):
            c.constant = svgSize.height
            
          default:
            break
          }
        }
        view.phoenixView.frame.size = svgSize
      }
      Swift.print("set frame: \(svgSize)")
      loadPage()
    }
  }
  
  private func loadPage() {
    doc?.render()
  }
}
