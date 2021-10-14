//
//  XibView.swift
//  Nimble
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import Cocoa

@IBDesignable
open class XibView: NSView, NibLoadable {
  
  public var contentView: NSView?
  
  private func loadFromNib() -> Void {
    guard let view = loadFromNib() else { return }
    
    view.frame = bounds
    view.autoresizingMask = [.width, .height]
      
    addSubview(view)
    contentView = view
  }
  
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadFromNib()
  }
  
  public override init(frame: NSRect) {
    super.init(frame: frame)
    loadFromNib()
  }
  
  open override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    loadFromNib()
    
    contentView?.prepareForInterfaceBuilder()
  }
}


public protocol NibLoadable: class {
  var nibName: String? { get }
  var nibBundle: Bundle { get }
}

extension NibLoadable {
  public var nibName: String? {
    return String(describing: type(of: self))
  }
  
  public var nibBundle: Bundle {
    return Bundle(for: type(of: self))
  }
}

extension NibLoadable where Self: NSView {
  public func loadFromNib() -> NSView? {
    guard let nibName = nibName else { return nil }
    
    var topLevelArray: NSArray? = nil
    nibBundle.loadNibNamed(NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
    
    return topLevelArray?.first { $0 is NSView} as? NSView
  }
}

public extension NSView {
  class func loadFromNib(_ nibName: String? = .none) -> Self {
    func loadAs<T: NSView>(_ nibName: String? = .none) -> T {
      let nibBundle = Bundle(for: T.self)
      var objectsArray: NSArray? = nil
      nibBundle.loadNibNamed(NSNib.Name(nibName ?? String(describing: T.self)), owner: self, topLevelObjects: &objectsArray)
      
      if let view = objectsArray?.first(where: { $0 is T }) as? T {
        return view
      }
      return T()
    }
    return loadAs(nibName)
  }
}
