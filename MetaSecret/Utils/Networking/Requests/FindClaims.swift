//
//  FindClaims.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 23.11.2022.
//

import Foundation

final class FindClaims: HTTPRequest {

    override init() {
        super.init()
        path = "findPasswordRecoveryClaims"
        guard let userSignature = userService.userSignature else { return }
        self.params = jsonService.jsonStringGeneration(from: userSignature) ?? "{}"
    }
}

struct FindClaimsResponse: Codable {
    var msgType: String?
    var data: [PasswordRecoveryRequest]?
    var error: String?
}
