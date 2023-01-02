//
//  Accept.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

final class Accept: HTTPRequest {
    init(candidate: UserSignature) {
        super.init()
        path = "accept"
        guard let userSignature = userService.userSignature else { return }
        let request = AcceptRequest(member: userSignature, candidate: candidate)
        self.params = jsonService.jsonStringGeneration(from: request) ?? "{}"
    }
}

//struct AcceptResult: Codable {
//    var msgType: String
//    var data: String?
//    var error: String?
//}

final class AcceptRequest: BaseModel {
    let member: UserSignature
    let candidate: UserSignature
    
    init(member: UserSignature, candidate: UserSignature) {
        self.member = member
        self.candidate = candidate
    }
}
