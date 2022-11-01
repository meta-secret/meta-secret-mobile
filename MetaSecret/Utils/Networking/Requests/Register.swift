//
//  Register.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

class Register: HTTPRequest, UD {
    typealias ResponseType = RegisterResult
    var params: [String : Any]?
    var path: String = "register"
    
    init() {
        guard let user = mainUser else { return }
        
        self.params = [
            "vaultName": user.name(),
            "device": ["deviceName": user.deviceName, "deviceId": user.deviceId],
            "publicKey": user.publicKey(),
            "rsaPublicKey": user.transportPublicKey(),
            "signature": user.userSignature()
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
