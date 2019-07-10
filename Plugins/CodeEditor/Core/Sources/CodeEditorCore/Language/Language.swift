//
//  Language.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 07.07.19.
//

import AppKit


public class Language: Decodable {
  public let id: String
  public let extensions: [String]
  
  public var grammar: LanguageGrammar? {
    return LanguageManager.shared.findGrammar(forLang: id)
  }
  
  public init(id: String, extensions: [String]) {
    self.id = id
    self.extensions = extensions
  }
}


public class LanguageGrammar: Decodable {
  public let language: String?
  public let scopeName: String
  public let path: Path

  private static let decoders: [String: GrammarDecoder.Type]  = [
    ".tmGrammar.json": JSONDecoder.self,
    ".tmLanguage.json": JSONDecoder.self
  ]
  
  public lazy var definition: GrammarDefinition? = {
    guard let decoder = LanguageGrammar.decoders.first(
      where: {self.path.basename().hasSuffix($0.key)})?.value else { return nil}
    
    return decoder.decode(from: path)
  }()
}


public final class LanguageManager {
  public private(set) var languages: [Language] = []
  public private(set) var grammars: [LanguageGrammar] = []
  
  public static let shared: LanguageManager = LanguageManager()
  
  public func add(language: Language) {
    self.languages.append(language)
  }
  
  public func add(grammar: LanguageGrammar) {
    self.grammars.append(grammar)
  }
  
  public func findLanguage(forExt ext: String) -> Language? {
    return languages.first { $0.extensions.contains(ext) }
  }
  
  public func findGrammar(forLang lang: String) -> LanguageGrammar? {
    return grammars.first {
      guard let gramLang = $0.language else { return false }
      return lang == gramLang
    }
  }
}


public extension File {
  var language: Language? {
    return LanguageManager.shared.findLanguage(forExt: self.extension)
  }
}
