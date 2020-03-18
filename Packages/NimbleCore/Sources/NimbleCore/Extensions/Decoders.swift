//
//  Decoders.swift
//  NimbleCore
//
//  Created by Grigory Markin on 05.11.19.
//  Copyright © 2019 SCADE. All rights reserved.
//


import Foundation

public extension YAMLDecoder {
  static func decode<T: Decodable>(from file: Path) -> T? {
    guard let content = try? String(contentsOf: file) else { return nil }
    do {
      return try YAMLDecoder().decode(T.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}

public extension PropertyListDecoder {
  static func decode<T: Decodable>(from file: Path) -> T? {
    guard let content = try? Data(contentsOf: file) else { return nil }
    do {
      return try PropertyListDecoder().decode(T.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}

public extension JSONDecoder {
  static func decode<T: Decodable>(from file: Path) -> T? {
    guard let content = try? Data(contentsOf: file) else { return nil }
    
    do {
      return try JSONDecoder().decode(T.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}
