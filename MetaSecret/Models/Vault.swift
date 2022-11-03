//
//  Vault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation

final class Vault: Codable, UD {
    var vaultName: String
    var signature: KeyFormat?
    var publicKey: KeyFormat?
    var transportPublicKey: KeyFormat?
    var device: Device?
    var declinedJoins: [Vault]?
    var pendingJoins: [Vault]?
    var signatures: [Vault]?
    
    func candidateRequest() -> [String: Any] {
        guard let mainUser else { return [String: Any]() }
        
        #warning("Use structure to JSon")
        return ["member": mainUser.createRequestJSon(),
                "candidate": createRequestJSon()
        ]
    }
    
    private func createRequestJSon() -> [String: Any] {
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
}
