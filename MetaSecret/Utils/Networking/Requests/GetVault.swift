//
//  GetVault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

class GetVault: HTTPRequest {
    typealias ResponseType = Vault
    var params: [String : Any]?
    var path: String = "getVault"
    
    init(vaultName: String, deviceName: String, publicKey: String, rsaPublicKey: String, signature: String) {
        self.params = [
            "vaultName": vaultName,
            "deviceName": deviceName,
            "publicKey": publicKey,
            "rsaPublicKey": rsaPublicKey,
            "signature": signature
        ]
    }
}
