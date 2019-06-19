//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation
import AppKit.NSColor

protocol Themable: AnyObject {
    
    var theme: Theme? { get }
}


struct Theme: Equatable, Codable {
    
    struct Style: Equatable {
        var color: NSColor
    }
    
    
    struct SelectionStyle: Equatable {
        var color: NSColor
        var usesSystemSetting: Bool
    }

    enum CodingKeys: String, CodingKey {
        case text
        case background
        case invisibles
        case selection
        case insertionPoint
        case lineHighlight
        
        case keywords
        case commands
        case types
        case attributes
        case variables
        case values
        case numbers
        case strings
        case characters
        case comments
        
        case metadata
    }
    
    
    
    // MARK: Public Properties
    
    /// name of the theme
    var name: String?
    
    // basic colors
    var text: Style
    var background: Style
    var invisibles: Style
    var selection: SelectionStyle
    var insertionPoint: Style
    var lineHighlight: Style
    
    var keywords: Style
    var commands: Style
    var types: Style
    var attributes: Style
    var variables: Style
    var values: Style
    var numbers: Style
    var strings: Style
    var characters: Style
    var comments: Style
    
    var metadata: Metadata?
    
    // MARK: -
    // MARK: Lifecycle
    
    init(contentsOf fileURL: URL) throws {
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        
        self = try decoder.decode(Theme.self, from: data)
        
        self.name = fileURL.deletingPathExtension().lastPathComponent
    }
    
    
    
    // MARK: Public Methods
    
    /// Is background color dark?
    var isDarkTheme: Bool {
        
        return self.background.color.lightnessComponent < self.text.color.lightnessComponent
    }
    
    
    /// selection color for inactive text view
    var secondarySelectionColor: NSColor? {
        
        return self.selection.usesSystemSetting ? nil : NSColor(calibratedWhite: self.selection.color.lightnessComponent, alpha: 1.0)
    }
    
    
    /// color for syntax type defined in theme
    func style(for type: SyntaxType) -> Style? {
        
        // The syntax key and theme keys must be the same.
        switch type {
        case .keywords: return self.keywords
        case .commands: return self.commands
        case .types: return self.types
        case .attributes: return self.attributes
        case .variables: return self.variables
        case .values: return self.values
        case .numbers: return self.numbers
        case .strings: return self.strings
        case .characters: return self.characters
        case .comments: return self.comments
        }
    }
    
}



// MARK: - Codable

extension Theme.Style: Codable {
    
    fileprivate static let invalidColor = NSColor.gray.usingColorSpace(.genericRGB)!
    
    private enum CodingKeys: String, CodingKey {
        
        case color
    }
    
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let colorCode = try container.decode(String.self, forKey: .color)
        self.color = NSColor(colorCode: colorCode) ?? Theme.Style.invalidColor
    }
    
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.color.colorCode(type: .hex), forKey: .color)
    }
    
}



extension Theme.SelectionStyle: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case color
        case usesSystemSetting
    }
    
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let colorCode = try container.decode(String.self, forKey: .color)
        self.color = NSColor(colorCode: colorCode) ?? Theme.Style.invalidColor
        
        self.usesSystemSetting = try container.decodeIfPresent(Bool.self, forKey: .usesSystemSetting) ?? false
    }
    
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.color.colorCode(type: .hex), forKey: .color)
        try container.encode(true, forKey: .usesSystemSetting)
    }
    
}
