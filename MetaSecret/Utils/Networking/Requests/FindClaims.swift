//
//  FindClaims.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 23.11.2022.
//

import Foundation

final class FindCalim: HTTPRequest, UD {
    typealias ResponseType = [PasswordRecoveryRequest]
    var params: String = "{}"
    var path: String = "findPasswordRecoveryClaims"
    
    init() {
        guard let userSignature else { return }
        self.params = userSignature.toJson()
    }
}
