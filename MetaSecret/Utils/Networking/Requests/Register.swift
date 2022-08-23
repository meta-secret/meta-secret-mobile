//
//  Register.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

class Register: HTTPRequest {
    typealias ResponseType = RegisterResult
    var params: [String : Any]?
    var path: String = "register"
    
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

struct RegisterResult: Codable {
    var status: RegisterStatusResult?
    var result: String?
}

enum RegisterStatusResult: String, Codable {
    case Registered = "registered"
    case AlreadyExists = "alreadyExists"
    case None = "none"
}
