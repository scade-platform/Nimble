//
//  ThemeManager.swift
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

final class ThemeManager {
     typealias Setting = Theme
    
    // MARK: Public Properties
    
    static let shared = ThemeManager()
    
    var theme: Theme?
    
    // MARK: Lifecycle
    
    private init() {
        
    }
    
    func loadDefaultDarkTheme() {
        theme = loadTheme(name: "DefaultDark")
    }
    
    // MARK: Private Methods
    
    private func loadTheme(name: String) -> Setting? {
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
        
        return bundle.url(forResource: name, withExtension: "theme", subdirectory: "Themes")
    }
    
    private func loadSetting(at fileURL: URL) throws -> Setting {
        return try Theme(contentsOf: fileURL)
    }
}
