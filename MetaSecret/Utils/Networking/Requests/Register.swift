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
    
    init(user: UserSignature) {
        self.params = user.toVault().createRequestJSon()
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
