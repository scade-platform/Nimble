//
//  Metadata.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

final class Metadata: NSObject, Codable {
    
    @objc dynamic var author: String?
    @objc dynamic var distributionURL: String?
    @objc dynamic var license: String?
    @objc dynamic var comment: String?
    
    
    var isEmpty: Bool {
        
        return self.author == nil && self.distributionURL == nil && self.license == nil && self.comment == nil
    }
    
    
    private enum CodingKeys: String, CodingKey {
        
        case author
        case distributionURL
        case license
        case comment = "description"  // `description` conflicts with NSObject's method.
    }
}
