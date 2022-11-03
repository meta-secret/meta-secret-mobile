//
//  JsonManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 31.10.2022.
//

import Foundation

class JsonManger {
    static func jsonU8Generation<T: Encodable>(from jsonStruct: T) -> [UInt8] {
        do {
            let jsonData = try JSONEncoder().encode(jsonStruct)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return [UInt8](Data((jsonString ?? "").utf8))
        } catch let _e {
            print(_e)
            return [UInt8]()
        }
    }
    
    static func jsonGeneration<T: Encodable>(from jsonStruct: T) -> String {
        do {
            let jsonData = try JSONEncoder().encode(jsonStruct)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            return jsonString
        } catch let _e {
            print(_e)
            return ""
        }
    }
    
    static func jsonDataGeneration<T: Encodable>(from jsonStruct: T) -> Data {
        do {
            let jsonData = try JSONEncoder().encode(jsonStruct)
            return jsonData
        } catch let _e {
            print(_e)
            return Data()
        }
    }
    
    static func object<T : Decodable>(from jsonString:String) throws -> T {
        let jsonData = Data(jsonString.utf8)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}
