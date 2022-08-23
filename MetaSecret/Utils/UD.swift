//
//  UD.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 14.08.2022.
//

import Foundation

protocol UD {
    func saveCustom<T: Codable>(object: T, key: String)
    func readCustom<T: Codable>(object: T.Type, key: String) -> T?
    mutating func resetAll()
    func saveRegisterStatus(_ status: RegisterStatusResult)
    
    var mainUser: User? { get set }
    var registerStatus: RegisterStatusResult { get }
}

extension UD {
    //MARK: - SAVE/LOAD CUSTOM
    func saveCustom<T: Codable>(object: T, key: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Unable to Encode \(T.self)")
        }
    }
    
    func readCustom<T: Codable>(object: T.Type, key: String) -> T? {
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
    
    //MARK: - RESET
    mutating func resetAll() {
        mainUser = nil
        saveRegisterStatus(.None)
    }
    
    //MARK: - VARIABLES
    var mainUser: User? {
        get {
            return readCustom(object: User.self, key: UDKeys.localVault)
        }
        set {}
    }
    
    var registerStatus: RegisterStatusResult {
        get {
            guard let status = UDManager.read(key: UDKeys.registerStatus) as? String else { return .None }
            return RegisterStatusResult(rawValue: status) ?? .None
        }
    }
    
    func saveRegisterStatus(_ status: RegisterStatusResult) {
        UDManager.save(value: status.rawValue, key: UDKeys.registerStatus)
    }
}

struct UDKeys {
    static let localVault = "localVault"
    static let registerStatus = "registerStatus"
}

fileprivate class UDManager {
    static let defaults = UserDefaults.standard
    
    //MARK: - DEFAULTS SAVE LOAD
    static func save<T>(value: T, key: String) {
        Self.defaults.set(value, forKey: key)
    }
    
    static func read(key: String) -> Any? {
        return Self.defaults.object(forKey: key)
    }
}
