//
//  Vault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation

final class Vault: Codable, UD {
    var vaultName: String
    var signature: Base64EncodedText?
    var publicKey: Base64EncodedText?
    var transportPublicKey: Base64EncodedText?
    var device: Device?
    var declinedJoins: [Vault]?
    var pendingJoins: [Vault]?
    var signatures: [Vault]?
    
    init(vaultName: String, signature: Base64EncodedText? = nil, publicKey: Base64EncodedText? = nil, transportPublicKey: Base64EncodedText? = nil, device: Device? = nil, declinedJoins: [Vault]? = nil, pendingJoins: [Vault]? = nil, signatures: [Vault]? = nil) {
        self.vaultName = vaultName
        self.signature = signature
        self.publicKey = publicKey
        self.transportPublicKey = transportPublicKey
        self.device = device
        self.declinedJoins = declinedJoins
        self.pendingJoins = pendingJoins
        self.signatures = signatures
    }
    
    func candidateRequest() -> [String: Any] {
        guard let mainVault else { return [String: Any]() }
        
        #warning("Use structure to JSon")
        return ["member": mainVault.createRequestJSon(),
                "candidate": createRequestJSon()
        ]
    }
    
    func createRequestJSon() -> [String: Any] {
        #warning("Use Structures")
        return ["vaultName": vaultName,
                "device": ["deviceName": device?.deviceName ?? "", "deviceId": device?.deviceId ?? ""],
                "publicKey": ["base64Text": publicKey?.base64Text ?? ""],
                "transportPublicKey": ["base64Text": transportPublicKey?.base64Text ?? ""],
        "signature": ["base64Text": signature?.base64Text ?? ""]]
    }
}

struct Device: Codable {
    var deviceName: String?
    var deviceId: String?
    
    init(deviceName: String? = nil, deviceId: String? = nil) {
        self.deviceName = deviceName
        self.deviceId = deviceId
    }
}
