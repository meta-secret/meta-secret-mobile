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
            "vaultName": user.userName,
            "device": ["deviceName": user.deviceName, "deviceId": user.deviceID],
            "publicKey": user.publicKey.base64EncodedString(),
            "rsaPublicKey": user.publicRSAKey.base64EncodedString(),
            "signature": user.signature?.base64EncodedString() ?? ""
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
