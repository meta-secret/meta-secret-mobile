//
//  AuthorizationService.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 02.01.2023.
//

import Foundation
import PromiseKit

protocol AuthorizationProtocol {
    func register(_ user: UserSignature) -> Promise<RegisterResult>
}

class AuthorisationService: APIManager, AuthorizationProtocol {
    func register(_ user: UserSignature) -> Promise<RegisterResult> {
        guard
            let params = jsonManager.jsonStringGeneration(from: user)
        else {
            return Promise(error: MetaSecretErrorType.userSignatureError)
        }
        
        return fetchData(Register(params))
    }
}
