//
//  Decline.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation

class Decline: HTTPRequest {
    typealias ResponseType = DeclineResult
    var params: [String : Any]?
    var path: String = "decline"
    
    init(candidate: Vault) {
        self.params = candidate.candidateRequest()
    }
}

struct DeclineResult: Codable {
    var status: String?
}
