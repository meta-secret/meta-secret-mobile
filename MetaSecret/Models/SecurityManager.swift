//
//  User.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit


struct UserSecurityBox: Codable {
    var signature: Base64EncodedText
    var keyManager: SerializedKeyManager
}

final class SecurityManager: BaseModel {
    var vaultName: String
    var signature: Base64EncodedText
    var keyManager: SerializedKeyManager? = nil
    var deviceName: String
    var deviceId: String
    
    init(vaultName: String, signature: Base64EncodedText, keyManager: SerializedKeyManager? = nil) {
        self.vaultName = vaultName
        self.signature = signature
        self.keyManager = keyManager
        self.deviceName = UIDevice.current.name
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}

struct SerializedKeyManager: Codable {
    var dsa: SerializedDsaKeyPair
    var transport: SerializedTransportKeyPair
}

struct SerializedDsaKeyPair: Codable {
    var keyPair: Base64EncodedText
    var publicKey: Base64EncodedText
}

struct SerializedTransportKeyPair: Codable {
    var secretKey: Base64EncodedText
    var publicKey: Base64EncodedText
}
