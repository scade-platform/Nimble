//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

enum SyntaxType: String, CaseIterable {
    
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
    
    var name: String {
        
        return self.rawValue
    }
    
}


enum SyntaxKey: String {
    
    case metadata
    case extensions
    case filenames
    case interpreters
    
    case commentDelimiters
    case outlineMenu
    case completions
    
    
    static let mappingKeys: [SyntaxKey] = [.extensions, .filenames, .interpreters]
}


enum SyntaxDefinitionKey: String {
    
    case keyString
    case beginString
    case endString
    case ignoreCase
    case regularExpression
}


enum DelimiterKey: String {
    
    case inlineDelimiter
    case beginDelimiter
    case endDelimiter
}
