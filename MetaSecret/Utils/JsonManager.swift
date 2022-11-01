//
//  JsonManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 31.10.2022.
//

import Foundation

class JsonManger {
    static func jsonDataGeneration<T: Encodable>(from jsonStruct: T) -> [UInt8] {
        do {
            let jsonData = try JSONEncoder().encode(jsonStruct)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return [UInt8](Data((jsonString ?? "").utf8))
        } catch let _e {
            print(_e)
            return [UInt8]()
        }
    }
    
    static func object<T : Decodable>(from jsonString:String) throws -> T {
        let jsonData = Data(jsonString.utf8)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}
