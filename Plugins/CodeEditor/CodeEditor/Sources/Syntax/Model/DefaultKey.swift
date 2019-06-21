//
//  DefaultKey.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

class DefaultKeys: RawRepresentable, Hashable, CustomStringConvertible {
    
    let rawValue: String
    
    
    required init(rawValue: String) {
        
        self.rawValue = rawValue
    }
    
    
    init(_ key: String) {
        
        self.rawValue = key
    }
    
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(self.rawValue)
    }
    
    
    var description: String {
        
         return self.rawValue
    }
    
}


final class DefaultKey<T>: DefaultKeys { }



extension UserDefaults {
    
    /// restore default value to factory default
    func restore<T>(key: DefaultKey<T>) {
        
        self.removeObject(forKey: key.rawValue)
    }
    
    
    /// return the initial value for key registered on `register(defaults:)`
    func registeredValue<T>(for key: DefaultKey<T>) -> T {
        
        return self.volatileDomain(forName: UserDefaults.registrationDomain)[key.rawValue] as! T
    }
    
    
    subscript(key: DefaultKey<Bool>) -> Bool {
        
        get { return self.bool(forKey: key.rawValue) }
        set { self.set(newValue, forKey: key.rawValue) }
    }
    
    
    subscript(key: DefaultKey<Int>) -> Int {
        
        get { return self.integer(forKey: key.rawValue) }
        set { self.set(newValue, forKey: key.rawValue) }
    }
    
    
    subscript(key: DefaultKey<UInt>) -> UInt {
        
        get { return UInt(exactly: self.integer(forKey: key.rawValue)) ?? 0 }
        set { self.set(newValue, forKey: key.rawValue) }
    }
    
    
    subscript(key: DefaultKey<Double>) -> Double {
        
        get { return self.double(forKey: key.rawValue) }
        set { self.set(newValue, forKey: key.rawValue) }
    }
    
    
    subscript(key: DefaultKey<CGFloat>) -> CGFloat {
        
        get { return CGFloat(self.double(forKey: key.rawValue)) }
        set { self.set(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: DefaultKey<String>) -> String? {
        
        get { return self.string(forKey: key.rawValue) }
        set { self.set(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: DefaultKey<[String]>) -> [String]? {
        
        get { return self.stringArray(forKey: key.rawValue) }
        set { self.set(newValue, forKey: key.rawValue) }
    }
    
    subscript<T>(key: DefaultKey<[T]>) -> [T] {
        
        get { return self.array(forKey: key.rawValue) as? [T] ?? [] }
        set { self.set(newValue, forKey: key.rawValue) }
    }
    
    
    subscript<T>(key: DefaultKey<T>) -> T where T: RawRepresentable, T.RawValue == Int {
        
        get {
            guard let value = T(rawValue: self.integer(forKey: key.rawValue)) else {
                let defaultValue = self.volatileDomain(forName: UserDefaults.registrationDomain)[key.rawValue] as? Int ?? 0
                return T(rawValue: defaultValue)!
            }
            
            return value
        }
        
        set { self.set(newValue.rawValue, forKey: key.rawValue) }
    }
    
}
