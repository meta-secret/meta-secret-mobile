//
//  UD.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 14.08.2022.
//

import Foundation

protocol UD {
    func saveCustom<T: Encodable>(object: T, key: String)
    func readCustom<T: Decodable>(object: T, key: String) -> T?
}

extension UD {
    func saveCustom<T: Encodable>(object: T, key: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Unable to Encode \(T.self)")
        }
    }
    
    func readCustom<T: Decodable>(object: T, key: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let object = try decoder.decode(T.self, from: data)
                return object
            } catch {
                print("Unable to Decode \(T.self)")
            }
        }
        return nil
    }
    
}

struct UDKeys {
    static let localVault = "localVault"
}
