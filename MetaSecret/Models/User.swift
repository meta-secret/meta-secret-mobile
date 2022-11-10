//
//  User.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit

class UserSignature: Codable {
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
    
    func toVault() -> Vault {
        let vault = Vault(vaultName: vaultName,
                          signature: KeyFormat(base64Text: signature),
                          publicKey: keyManager?.dsa.publicKey,
                          transportPublicKey: keyManager?.transport.publicKey,
                          device: Device(deviceName: deviceName, deviceId: deviceId),
                          declinedJoins: nil,
                          pendingJoins: nil,
                          signatures: nil,
                          isVirtual: false)
        return vault
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
    
    init(base64Text: String) {
        self.base64Text = base64Text
    }
}

private final class UserRequest: Codable {
    var vaultName: String
    var signature: String
    var device: Device
    var publicKey: KeyFormat
    var transportPublicKey: KeyFormat
    
    init(vaultName: String, signature: String, device: Device, publicKey: KeyFormat, transportPublicKey: KeyFormat) {
        self.vaultName = vaultName
        self.signature = signature
        self.device = device
        self.publicKey = publicKey
        self.transportPublicKey = transportPublicKey
    }
}
