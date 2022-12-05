//
//  Decline.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation

final class Decline: HTTPRequest, UD {
    typealias ResponseType = DeclineResult
    var params: String = "{}"
    var path: String = "decline"
    
    init(candidate: UserSignature) {
        guard let userSignature else { return }
        let request = AcceptRequest(member: userSignature, candidate: candidate)
        self.params = request.toJson()
    }
}

struct DeclineResult: Codable {
    var status: String?
}
