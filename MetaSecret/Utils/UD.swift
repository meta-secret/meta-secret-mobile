//
//  UD.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 14.08.2022.
//

import Foundation

protocol UD: AnyObject {
    func resetAll()
    
    var userSignature: UserSignature? { get set }
    var mainVault: VaultDoc? { get set }
    var securityBox: UserSecurityBox? { get set }
    var deviceStatus: VaultInfoStatus { get set }
    var shouldShowVirtualHint: Bool {get set}
    var isFirstAppLaunch: Bool {get set}
    var isOwner: Bool {get set}
    var shouldShowOnboarding: Bool {get set}
}

extension UD {
    //MARK: - RESET
    func resetAll() {
        userSignature = nil
        securityBox = nil
        deviceStatus = .unknown
    }
    
    //MARK: - VARIABLES
    var userSignature: UserSignature? {
        get {
            return UDManager.readCustom(object: UserSignature.self, key: UDKeys.userSignature)
        }
        set {
            UDManager.saveCustom(object: newValue, key: UDKeys.userSignature)
        }
    }

    var mainVault: VaultDoc? {
        get {
            return UDManager.readCustom(object: VaultDoc.self, key: UDKeys.localVault)
        }
        set {
            UDManager.saveCustom(object: newValue, key: UDKeys.localVault)
        }
    }
    
    var securityBox: UserSecurityBox? {
        get {
            return UDManager.readCustom(object: UserSecurityBox.self, key: UDKeys.securityBox)
        }
        set {
            UDManager.saveCustom(object: newValue, key: UDKeys.securityBox)
        }
    }
    
    var deviceStatus: VaultInfoStatus {
        get {
            guard let status = UDManager.read(key: UDKeys.deviceStatus) as? String else { return .unknown }
            return VaultInfoStatus(rawValue: status) ?? .unknown
        }
        
        set {
            UDManager.save(value: newValue.rawValue, key: UDKeys.deviceStatus)
        }
    }
    
    var shouldShowVirtualHint: Bool {
        get {
            guard let status = UDManager.read(key: UDKeys.shouldShowVirtualHint) as? Bool else { return true }
            return status
        }
        
        set {
            UDManager.save(value: newValue, key: UDKeys.shouldShowVirtualHint)
        }
    }
    
    var isFirstAppLaunch: Bool {
        get {
            guard let status = UDManager.read(key: UDKeys.isFirstAppLaunch) as? Bool else { return true }
            return status
        }
        
        set {
            UDManager.save(value: newValue, key: UDKeys.isFirstAppLaunch)
        }
    }
    
    var isOwner: Bool {
        get {
            guard let status = UDManager.read(key: UDKeys.isOwner) as? Bool else { return false }
            return status
        }
        
        set {
            UDManager.save(value: newValue, key: UDKeys.isOwner)
        }
    }
    
    var shouldShowOnboarding: Bool {
        get {
            guard let status = UDManager.read(key: UDKeys.shouldShowOnboarding) as? Bool else { return true }
            return status
        }
        
        set {
            UDManager.save(value: newValue, key: UDKeys.shouldShowOnboarding)
        }
    }
}

//MARK: - KEYS
struct UDKeys {
    static let userSignature = "userSignature"
    static let localVault = "localVault"
    static let securityBox = "securityBox"
    static let deviceStatus = "deviceStatus"
    static let shouldShowVirtualHint = "shouldShowVirtualHint"
    static let vUsers = "vUsers"
    static let isFirstAppLaunch = "isFirstAppLaunch"
    static let isOwner = "isOwner"
    static let shouldShowOnboarding = "shouldShowOnboarding"
}

//MARK: - UDMANAGER
fileprivate class UDManager {
    static let defaults = UserDefaults.standard
    
    //MARK: - DEFAULTS SAVE LOAD
    static func save<T>(value: T, key: String) {
        Self.defaults.set(value, forKey: key)
    }
    
    static func read(key: String) -> Any? {
        return Self.defaults.object(forKey: key)
    }
    
    //MARK: - SAVE/LOAD CUSTOM
    static func saveCustom<T: Codable>(object: T, key: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("## Unable to Encode \(T.self)")
        }
    }
    
    static func readCustom<T: Codable>(object: T.Type, key: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let object = try decoder.decode(T.self, from: data)
                return object
            } catch {
                print("## Unable to Decode \(T.self)")
            }
        }
        return nil
    }
}
