//
//  JsonManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 31.10.2022.
//

import Foundation
protocol JsonSerealizable {
    func jsonU8Generation(from string: String) -> [UInt8]
    func jsonU8Generation<T: Encodable>(from jsonStruct: T) -> [UInt8]?
    func jsonGeneration<T: Encodable>(from jsonStruct: T) -> String?
    func jsonDataGeneration<T: Encodable>(from jsonStruct: T) -> Data?
    func object<T : Decodable>(from jsonString:String) throws -> T?
    func array<T: Decodable>(from jsonString: String) throws -> [T]?
}

extension JsonSerealizable {
    func jsonU8Generation(from string: String) -> [UInt8] {
        return [UInt8](Data(string.utf8))
    }
    
    func jsonU8Generation<T: Encodable>(from jsonStruct: T) -> [UInt8]? {
        do {
            let jsonData = try JSONEncoder().encode(jsonStruct)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return [UInt8](Data((jsonString ?? "").utf8))
        } catch let _e {
            print(_e)
            return nil
        }
    }
    
    func jsonGeneration<T: Encodable>(from jsonStruct: T) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(jsonStruct)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            return jsonString
        } catch let _e {
            print(_e)
            return nil
        }
    }
    
    func jsonDataGeneration<T: Encodable>(from jsonStruct: T) -> Data? {
        do {
            let jsonData = try JSONEncoder().encode(jsonStruct)
            return jsonData
        } catch let _e {
            print(_e)
            return nil
        }
    }
    
    func object<T : Decodable>(from jsonString:String) -> T? {
        do {
            let jsonData = Data(jsonString.utf8)
            return try JSONDecoder().decode(T.self, from: jsonData)
        } catch let e {
            print(e.localizedDescription)
            return nil
        }
    }
    
    func array<T: Decodable>(from jsonString: String) -> [T]? {
        do {
            var components = [T]()
            let jsonData = Data(jsonString.utf8)
            let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
            if let jsonResult = jsonResult as? [[String: Any]] {
                for item in jsonResult {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: item) {
                        let item = try JSONDecoder().decode(T.self, from: jsonData)
                        components.append(item)
                    }
                }
            }
            
            return components
        } catch let e {
            print(e.localizedDescription)
            return nil
        }
    }
}
