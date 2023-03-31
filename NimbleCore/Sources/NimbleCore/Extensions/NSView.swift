//
//  NSViewExtensions.swift
//  NimbleCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
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

extension NSView {
  /// TODO: get rid of this method, some specific NSViews have their own background properties
  /// and this method confuses as calling it does not make what it's expected in such cases
  public func setBackgroundColor(_ color: NSColor) {
    let current = NSAppearance.current
    NSAppearance.current =  NSApp.appearance //self.effectiveAppearance

    if self.layer == .none {
      self.layer = CALayer()
    }
    self.layer?.backgroundColor = color.cgColor

    NSAppearance.current = current

  }

  public func bringToFront() {
    var ctx = self
    self.superview?.sortSubviews({(view1, view2, ptr) in
      let view = ptr?.load(as: NSView.self)
      switch view {
       case view1:
           return ComparisonResult.orderedDescending
       case view2:
           return ComparisonResult.orderedAscending
       default:
           return ComparisonResult.orderedSame
       }
    }, context: &ctx)
  }
}
