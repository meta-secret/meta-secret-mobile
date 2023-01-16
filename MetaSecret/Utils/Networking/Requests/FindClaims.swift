//
//  FindClaims.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 23.11.2022.
//

import Foundation

final class FindClaims: HTTPRequest {
    var ignorable: Bool { return true }
    var params: String
    var path: String { return "findPasswordRecoveryClaims" }
    
    init(_ params: String) {
        self.params = params
    }
}

struct FindClaimsResult: Codable {
    var msgType: String?
    var data: [PasswordRecoveryRequest]?
    var error: String?
}
