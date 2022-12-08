//
//  FindClaims.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 23.11.2022.
//

import Foundation

final class FindClaims: HTTPRequest, UD {
    typealias ResponseType = FindClaimsResponse
    var params: String = "{}"
    var path: String = "findPasswordRecoveryClaims"
    
    init() {
        guard let userSignature else { return }
        self.params = userSignature.toJson()
    }
}

struct FindClaimsResponse: Codable {
    var msgType: String?
    var data: [PasswordRecoveryRequest]?
    var error: String?
}
