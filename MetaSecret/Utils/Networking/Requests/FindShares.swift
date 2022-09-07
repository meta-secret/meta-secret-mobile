//
//  FindShares.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

class FindShares: HTTPRequest, UD {
    typealias ResponseType = FindSharesResult
    var params: [String : Any]?
    var path: String = "findShares"
    
    init() {
        guard let user = mainUser else { return }
        
        self.params = [
            "vaultName": user.userName,
            "device": ["deviceName": user.deviceName, "deviceId": user.deviceID],
            "publicKey": user.publicKey.base64EncodedString(),
            "rsaPublicKey": user.publicRSAKey.base64EncodedString(),
            "signature": user.signature?.base64EncodedString() ?? ""
        ]
    }
}

struct FindSharesResult: Codable {
    var status: VaultInfoStatus = .unknown
    var vault: Vault?
}
