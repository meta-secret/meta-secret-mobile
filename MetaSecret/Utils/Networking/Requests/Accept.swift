//
//  Accept.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

final class Accept: HTTPRequest {
    var params: String
    var path: String { return "accept" }
    
    init(_ params: String) {
        self.params = params
    }
}

struct AcceptResult: Codable {
    var msgType: String
    var data: String?
    var error: String?
}

final class AcceptRequest: BaseModel {
    let member: UserSignature
    let candidate: UserSignature
    
    init(member: UserSignature, candidate: UserSignature) {
        self.member = member
        self.candidate = candidate
    }
}
