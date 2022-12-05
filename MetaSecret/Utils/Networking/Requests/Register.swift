//
//  Register.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

final class Register: HTTPRequest, UD {
    typealias ResponseType = RegisterResult
    var params: String = "{}"
    var path: String = "register"
    
    init(_ userSignature: UserSignature) {
        self.params = userSignature.toJson()
    }
}

struct RegisterResult: Codable {
    var data: RegisterStatusResult?
    var msgType: String
    var error: String?
}

enum RegisterStatusResult: String, Codable {
    case Registered = "registered"
    case AlreadyExists = "alreadyExists"
    case None = "none"
}
