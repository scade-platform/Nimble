//
//  NSViewController.swift
//  NimbleCores
//
//  Created by Grigory Markin on 13.06.19.
//

import Cocoa

extension NSViewController {
  public static func loadFromNib() -> Self {
    func instantiateFromNib<T: NSViewController>() -> T {
      return T.init(nibName: String(describing: T.self), bundle: Bundle(for: T.self))
    }
    
    return instantiateFromNib()
  }
}
