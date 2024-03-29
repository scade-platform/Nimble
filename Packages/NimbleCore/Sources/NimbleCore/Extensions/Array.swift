//
//  Array.swift
//  NimbleCore
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


public extension Array {
  subscript(safe index: Int) -> Element? {
    guard index >= 0, index < endIndex else { return nil }
    return self[index]
  }

  subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
    guard index >= 0, index < endIndex else { return defaultValue() }
    return self[index]
  }
}
