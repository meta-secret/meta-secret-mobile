//
//  Decline.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation

final class Decline: HTTPRequest {
    init(candidate: UserSignature) {
        super.init()
        path = "decline"
        guard let userSignature = userService.userSignature else { return }
        let request = AcceptRequest(member: userSignature, candidate: candidate)
        self.params = jsonService.jsonStringGeneration(from: request) ?? "{}"
    }
}

struct DeclineResult: Codable {
    var status: String?
}
