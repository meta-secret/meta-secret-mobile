//
//  JsonManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 31.10.2022.
//

import Foundation
protocol JsonSerealizable {
    func jsonU8Generation(string: String) -> [UInt8]
    func jsonU8Generation<T: Encodable>(from structure: T) -> [UInt8]?
    func jsonStringGeneration<T: Encodable>(from structure: T) -> String?
    func jsonDataGeneration<T: Encodable>(from structure: T) -> Data?
    func objectGeneration<T : Decodable>(from jsonString:String) throws -> T?
    func arrayGeneration<T: Decodable>(from jsonString: String) throws -> [T]?
}

final class JsonSerealizManager: NSObject, JsonSerealizable {
    override init() {
    }
    
    func jsonU8Generation(string: String) -> [UInt8] {
        return [UInt8](Data(string.utf8))
    }
    
    func jsonU8Generation<T: Encodable>(from structure: T) -> [UInt8]? {
        do {
            let jsonData = try JSONEncoder().encode(structure)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return [UInt8](Data((jsonString ?? "").utf8))
        } catch let e {
            print("## \(e.localizedDescription)")
            return nil
        }
    }
    
    func jsonStringGeneration<T: Encodable>(from structure: T) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(structure)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            return jsonString
        } catch let e {
            print("## \(e.localizedDescription)")
            return nil
        }
    }
    
    func jsonDataGeneration<T: Encodable>(from structure: T) -> Data? {
        do {
            let jsonData = try JSONEncoder().encode(structure)
            return jsonData
        } catch let e {
            print("## \(e.localizedDescription)")
            return nil
        }
    }
    
    func objectGeneration<T : Decodable>(from jsonString: String) -> T? {
        do {
            let jsonData = Data(jsonString.utf8)
            return try JSONDecoder().decode(T.self, from: jsonData)
        } catch let e {
            print("## \(e.localizedDescription)")
            return nil
        }
    }
    
    func arrayGeneration<T: Decodable>(from jsonString: String) -> [T]? {
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
            print("## \(e.localizedDescription)")
            return nil
        }
    }
}
