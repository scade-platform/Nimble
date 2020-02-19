//
//  Language.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 07.07.19.
//

import AppKit
import NimbleCore


public final class Language: Decodable {
  private enum CodingKeys: String, CodingKey {
    case id, configuration, extensions, aliases, mimetypes, filenames, filenamePatterns, firstline
  }
  
  public let id: String
  public let configpath: Path?
  public let extensions: [String]
  public let aliases: [String]
  public let mimetypes: [String]
  public let filenames: [String]
  public let filenamePatterns: [String]
  public let firstline: String?
  
    
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.id = try container.decode(String.self, forKey: .id)
    self.configpath = try container.decodeIfPresent(Path.self, forKey: .configuration)
    self.extensions = try container.decodeIfPresent([String].self, forKey: .extensions) ?? []
    self.aliases = try container.decodeIfPresent([String].self, forKey: .aliases) ?? []
    self.mimetypes = try container.decodeIfPresent([String].self, forKey: .mimetypes) ?? []
    self.filenames = try container.decodeIfPresent([String].self, forKey: .filenames) ?? []
    self.filenamePatterns = try container.decodeIfPresent([String].self, forKey: .filenamePatterns) ?? []
    self.firstline = try container.decodeIfPresent(String.self, forKey: .firstline)
  }
    
  public var grammar: LanguageGrammar? {
    return LanguageManager.shared.findGrammar(forLang: id)
  }
}

extension Language: Equatable {
  public static func == (lhs: Language, rhs: Language) -> Bool {
    return lhs.id == rhs.id
  }
}


// MARK: -

public final class LanguageGrammar: Decodable, TokenizerRepository {
  public let language: String?
  public let scopeName: String
  public var path: Path
  
  private static let decoders: [String: GrammarDecoder.Type]  = [
    ".tmGrammar.json": JSONDecoder.self,
    ".tmLanguage.json": JSONDecoder.self
  ]
  
  private lazy var repository = grammar?.buildRepository(with: self)
  
  private lazy var grammar: Grammar? = {
    guard let decoder = LanguageGrammar.decoders.first(
      where: {self.path.basename().hasSuffix($0.key)})?.value else { return nil}    
    return decoder.decode(from: path)
  }()
  
  public lazy var scope: SyntaxScope = {
    SyntaxScope(self.scopeName)
  }()
  
  public lazy var tokenizer: Tokenizer? = grammar?.createTokenizer(with: self)
  
  public init(language: String? = nil, scopeName: String, path: Path) {
    self.language = language
    self.scopeName = scopeName
    self.path = path
  }
  
  public func preload() {
    let _ = self.tokenizer
  }
  
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
  
  public static let shared: LanguageManager = {
    let languageManager = LanguageManager()
    
    if let codeEditorPlugin = PluginManager.shared.plugins["com.scade.nimble.CodeEditor"] {
      languageManager.languages = codeEditorPlugin.extensions([Language].self, at: "languages").flatMap{$0}
      languageManager.grammars = codeEditorPlugin.extensions([LanguageGrammar].self, at: "grammars").flatMap{$0}
    }
      
    return languageManager
  }()
  
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
    return LanguageManager.shared.findLanguage(forExt: ".\(self.extension)")
  }
}
