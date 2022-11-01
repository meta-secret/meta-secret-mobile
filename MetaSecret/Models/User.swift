//
//  User.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit

final class UserSignature: Codable {
    var vaultName: String
    var signature: String
    var keyManager: SerializedKeyManager? = nil
    var deviceName: String
    var deviceId: String
    
    init(vaultName: String = "", signature: String = "", keyManager: SerializedKeyManager? = nil) {
        self.vaultName = vaultName
        self.signature = signature
        self.keyManager = keyManager
        self.deviceName = UIDevice.current.name
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    func publicKey() -> String {
        return keyManager?.dsa.publicKey.base64Text ?? ""
    }
    
    func transportPublicKey() -> String {
        return keyManager?.transport.publicKey.base64Text ?? ""
    }
    
    func name() -> String {
        return vaultName
    }
    
    func userSignature() -> String {
        return signature
    }
}

struct SerializedKeyManager: Codable {
    var dsa: SerializedDsaKeyPair
    var transport: SerializedTransportKeyPair
}

struct SerializedDsaKeyPair: Codable {
    var keyPair: KeyFormat
    var publicKey: KeyFormat
}

struct SerializedTransportKeyPair: Codable {
    var secretKey: KeyFormat
    var publicKey: KeyFormat
}


struct KeyFormat: Codable {
    var base64Text: String
}
