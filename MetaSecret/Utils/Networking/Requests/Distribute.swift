//
//  Distribute.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation

class Distribute: HTTPRequest {
    typealias ResponseType = DistributeResult
    var params: [String : Any]?
    var path: String = "distribute"
    
    init(user: User) {
        self.params = [
            "vaultName": user.userName,
            "deviceName": user.deviceName,
            "publicKey": user.publicKey.base64EncodedString(),
            "rsaPublicKey": user.publicRSAKey.base64EncodedString(),
            "signature": user.signature?.base64EncodedString()
        ]
    }
}

struct DistributeResult: Codable {
    var status: String
}
