//
//  Accept.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

final class Accept: HTTPRequest, UD {
    typealias ResponseType = AcceptResult
    var params: [String : Any]?
    var path: String = "accept"
    
    init(candidate: Vault) {
        self.params = candidate.candidateRequest()
    }
}

struct AcceptResult: Codable {
    var status: String?
}
