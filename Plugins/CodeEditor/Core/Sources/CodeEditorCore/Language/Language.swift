//
//  Language.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 07.07.19.
//

import AppKit


public final class Language: Decodable {
  public let id: String
  public let extensions: [String]
  
  public init(id: String, extensions: [String]) {
    self.id = id
    self.extensions = extensions
  }
  
  public var grammar: LanguageGrammar? {
    return LanguageManager.shared.findGrammar(forLang: id)
  }
}


// MARK: -

public final class LanguageGrammar: Decodable, TokenizerRepository {
  public let language: String?
  public let scopeName: String
  public let path: Path

  private static let decoders: [String: GrammarDecoder.Type]  = [
    ".tmGrammar.json": JSONDecoder.self,
    ".tmLanguage.json": JSONDecoder.self
  ]
  
  public init(language: String? = nil, scopeName: String, path: Path) {
    self.language = language
    self.scopeName = scopeName
    self.path = path
  }
  
  public lazy var scope: SyntaxScope = {
    SyntaxScope(self.scopeName)
  }()
  
  private lazy var grammar: Grammar? = {
    guard let decoder = LanguageGrammar.decoders.first(
      where: {self.path.basename().hasSuffix($0.key)})?.value else { return nil}
    
    let t1 = mach_absolute_time()
    let g = decoder.decode(from: path)
    let t2 = mach_absolute_time()
    
    print("Load time: \( Double(t2 - t1) * 1E-9)")
    
    return g
  }()
  
  
  private lazy var repository = grammar?.buildRepository(with: self)
  public lazy var tokenizer: Tokenizer? = grammar?.createTokenizer(with: self)
    
  public subscript(ref: GrammarRef) -> Tokenizer? {
    switch ref {
    case .local(let val):
      return repository?[val]
    case .this:
      return tokenizer
    default:
      return nil
    }
  }
}



// MARK: -


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


// MARK: -


public extension File {
  var language: Language? {
    return LanguageManager.shared.findLanguage(forExt: self.extension)
  }
}
