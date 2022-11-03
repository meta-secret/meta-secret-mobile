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
    
    func createRequestJSon() -> [String: Any] {
//        guard let keyManager else { return [String: Any]()}
//
//        let device = DeviceRequest(deviceName: deviceName, deviceId: deviceId)
//        let request = UserRequest(vaultName: vaultName, signature: signature, device: device, publicKey: keyManager.dsa.publicKey, transportPublicKey: keyManager.transport.publicKey)
        #warning("Use Structures")
        return ["vaultName": vaultName,
                "device": ["deviceName": deviceName, "deviceId": deviceId],
                "publicKey": ["base64Text": publicKey()],
                "transportPublicKey": ["base64Text": transportPublicKey()],
                "signature": ["base64Text": signature]]
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

//final class DeviceRequest: Codable {
//    var deviceName: String
//    var deviceId: String
//
//    init(deviceName: String, deviceId: String) {
//        self.deviceName = deviceName
//        self.deviceId = deviceId
//    }
//}
