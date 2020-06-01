//
//  String.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 28.05.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Foundation

extension String {
  subscript(range: NSRange) -> String? {
    guard let range = Range(range) else { return nil }
    return String(self[range])
  }
}
