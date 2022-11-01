//
//  Distribute.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation

class Distribute: HTTPRequest, UD {
    typealias ResponseType = DistributeResult
    var params: [String : Any]?
    var path: String = "distribute"
    
    init(encryptedShare: String) {
        guard let user = mainUser else { return }
        
        self.params = [
            "vaultName": user.name(),
            "deviceName": user.deviceName,
            "publicKey": user.publicKey(),
            "rsaPublicKey": user.transportPublicKey(),
            "signature": user.userSignature(),
            "encryptedText": encryptedShare
        ]
    }
}

struct DistributeResult: Codable {
    var status: String
}
