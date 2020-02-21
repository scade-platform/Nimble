//
//  XibView.swift
//  Nimble
//
//  Created by Grigory Markin on 05.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
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
