//
//  Register.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

final class Register: HTTPRequest {
    init(_ userSignature: UserSignature) {
        super.init()
        path = "register"
        self.params = jsonService.jsonStringGeneration(from: userSignature) ?? "{}"
    }
}

//struct RegisterResult: Codable {
//    var data: RegisterStatusResult?
//    var msgType: String
//    var error: String?
//}

enum RegisterStatusResult: String, Codable {
    case Registered = "registered"
    case AlreadyExists = "alreadyExists"
    case None = "none"
}
