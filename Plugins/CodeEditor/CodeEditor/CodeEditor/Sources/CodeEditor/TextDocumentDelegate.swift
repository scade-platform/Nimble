//
//  CodeCompletion.swift
//  CodeCompletion
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore

public protocol TextDocumentDelegate {
  init(doc: TextDocument)
  
  func complete() -> [String]
}


public class TextDocumentDelegateManager {
  private var delegateClasses: [String: [TextDocumentDelegate.Type]] = [:]
  
  public static let shared: TextDocumentDelegateManager = TextDocumentDelegateManager()
  
  public func registerTextDocumentDelegate<T: TextDocumentDelegate>(_ delegateClass: T.Type, for languageId: String) {
    if var classes = delegateClasses[languageId] {
      classes.append(delegateClass)
    } else {
      delegateClasses[languageId] = [delegateClass]
    }
  }
  
  public func createDelegates(for doc: TextDocument) -> [TextDocumentDelegate] {
    guard let classes = delegateClasses[doc.languageId] else {return []}
    return classes.map{ $0.init(doc: doc)}
  }
}
