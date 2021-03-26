//
//  Language.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 07.07.19.
//

import AppKit
import NimbleCore


// MARK: - Language

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
    return LanguageManager.shared.findGrammar(language: id)
  }

  public lazy var configuration: LanguageConfiguration? = {
    guard let path = self.configpath,
          let data = try? Data(contentsOf: path) else { return nil }

    do {
      return try JSONDecoder().decode(LanguageConfiguration.self, from: data)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
    
  }()
}


extension Language: Equatable {
  public static func == (lhs: Language, rhs: Language) -> Bool {
    return lhs.id == rhs.id
  }
}

// MARK: - Language configuration

public struct LanguageConfiguration: Decodable {
  private enum CodingKeys: String, CodingKey { case comments, autoClosingPairs }

  public var comments: Comments?

  public var autoClosingPairs: [(String, String)]


  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.comments = try container.decodeIfPresent(Comments.self, forKey: .comments)

    let autoClosingPairs = try container.decodeIfPresent([[String]].self, forKey: .autoClosingPairs) ?? []
    self.autoClosingPairs = autoClosingPairs.compactMap {
      guard let start = $0.first, let end = $0.last else { return nil}
      return (start, end)
    }
  }

  // Comments struct

  public struct Comments: Decodable {
    private enum CodingKeys: String, CodingKey { case lineComment, blockComment }

    public var lineComment: String?
    public var blockComment: (start: String, end: String)?

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      self.lineComment = try container.decodeIfPresent(String.self, forKey: .lineComment)

      let blockComment = try container.decodeIfPresent([String].self, forKey: .blockComment)
      if let start = blockComment?.first, let end = blockComment?.last {
        self.blockComment = (start, end)
      }
    }
  }
}


// MARK: - Language grammar

public final class LanguageGrammar: Decodable, TokenizerRepository {
  public let language: String?
  public let scopeName: String
  public var path: Path
  
  private static let decoders: [String: GrammarDecoder.Type]  = [
    ".tmLanguage": PropertyListDecoder.self,
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



// MARK: - Language manager

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
  
  public func findLanguage(fileExtension ext: String) -> Language? {
    return languages.first { $0.extensions.contains(ext) }
  }

  public func findLanguage(fileName name: String) -> Language? {
    return languages.first { $0.filenames.contains(name) }
  }

  public func findGrammar(language lang: String) -> LanguageGrammar? {
    return grammars.first {
      guard let gramLang = $0.language else { return false }
      return lang == gramLang
    }
  }
}

// MARK: - Extensions

public extension File {
  var language: Language? {
    if let lang = LanguageManager.shared.findLanguage(fileName: self.name) {
      return lang
    }

    return LanguageManager.shared.findLanguage(fileExtension: ".\(self.extension)")
  }
}
