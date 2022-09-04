//
//  GetVault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

class GetVault: HTTPRequest {
    typealias ResponseType = GetVaultResult
    var params: [String : Any]?
    var path: String = "getVault"
    
    init(user: User) {
        self.params = [
            "vaultName": user.userName,
            "device": ["deviceName": user.deviceName, "deviceId": user.deviceID],
            "publicKey": user.publicKey.base64EncodedString(),
            "rsaPublicKey": user.publicRSAKey.base64EncodedString(),
            "signature": user.signature?.base64EncodedString() ?? ""
        ]
    }
}

struct GetVaultResult: Codable {
    var status: VaultInfoStatus = .unknown
    var vault: Vault?
}

enum VaultInfoStatus: String, Codable {
    case member
    case pending
    case declined
    case unknown
}
