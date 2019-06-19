//
//  SyntaxManager.swift
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation
import Yams

enum BundledStyleName {
    static let none: SyntaxManager.SettingName = "None"
    static let xml: SyntaxManager.SettingName = "XML"
    static let markdown: SyntaxManager.SettingName = "Markdown"
}

final class SyntaxManager {
    
    typealias Setting = SyntaxStyle
    
    typealias SettingName = String
    typealias StyleDictionary = [String: Any]
    
    // MARK: Public Properties
    
    static let shared = SyntaxManager()
    
    var style: SyntaxStyle?
    
    // MARK: Lifecycle
    
    private init() {
        
    }
    
    // MARK: Setting File Managing
 
    func loadSwiftSyntax() {
        style = loadSyntax(name: "Swift")
    }
    
    // MARK: Private Methods
 
    private func loadSyntax(name: String) -> Setting? {
        guard let setting: Setting = {
            guard let url = urlForBundledSetting(name: name) else {
                return nil
            }
            
            let setting = try? loadSetting(at: url)
            
            return setting
            }() else {
                return nil
        }
        
        return setting
    }
    
    /// return a setting file URL in the application's Resources domain or nil if not exists
    private func urlForBundledSetting(name: String) -> URL? {
        guard let bundle = Bundle(identifier: "com.scade.nimble.CodeEditor") else {
            return nil
        }
        
        return bundle.url(forResource: name, withExtension: "yaml", subdirectory: "Syntaxes")
    }
    
    /// create setting name from a URL (don't care if it exists)
    private func settingName(from fileURL: URL) -> String {
        return fileURL.deletingPathExtension().lastPathComponent
    }
    
    
    /// load setting from the file at given URL
    private func loadSetting(at fileURL: URL) throws -> Setting {
        
        let dictionary = try loadSettingDictionary(at: fileURL)
        let name = settingName(from: fileURL)
        
        return SyntaxStyle(dictionary: dictionary, name: name)
    }
    
    /// Load StyleDictionary at file URL.
    ///
    /// - Parameter fileURL: URL to a setting file.
    /// - Throws: `CocoaError`
    private func loadSettingDictionary(at fileURL: URL) throws -> StyleDictionary {
        
        let fileContent = try String(contentsOf: fileURL)
        guard let loadedDictionary = try Yams.load(yaml: fileContent) as? [String: Any] else {
            return StyleDictionary()
            
        }
    
        return loadedDictionary
    }
}
