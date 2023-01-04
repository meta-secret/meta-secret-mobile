//
//  VaultAPIService.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 02.01.2023.
//

import Foundation
import PromiseKit

protocol VaultAPIProtocol {
    func getVault() -> Promise<GetVaultResult>
    func accept(_ candidate: UserSignature) -> Promise<AcceptResult>
    func decline(_ candidate: UserSignature) -> Promise<AcceptResult>
}

class VaultAPIService: APIManager, VaultAPIProtocol {
    func getVault() -> Promise<GetVaultResult> {
        guard
            let userSignature = userService.userSignature,
            let params = jsonManager.jsonStringGeneration(from: userSignature)
        else {
            return Promise(error: MetaSecretErrorType.userSignatureError)
        }
        
        return fetchData(GetVault(params))
    }
    
    func accept(_ candidate: UserSignature) -> Promise<AcceptResult> {
        guard
            let userSignature = userService.userSignature
        else {
            return Promise(error: MetaSecretErrorType.userSignatureError)
        }
        
        let request = AcceptRequest(member: userSignature, candidate: candidate)
        guard let params = jsonManager.jsonStringGeneration(from: request) else {
            return Promise(error: MetaSecretErrorType.networkError)
        }
        
        return fetchData(Accept(params))
    }
    
    func decline(_ candidate: UserSignature) -> Promise<AcceptResult> {
        guard
            let userSignature = userService.userSignature
        else {
            return Promise(error: MetaSecretErrorType.userSignatureError)
        }
        
        let request = AcceptRequest(member: userSignature, candidate: candidate)
        guard let params = jsonManager.jsonStringGeneration(from: request) else {
            return Promise(error: MetaSecretErrorType.networkError)
        }
        
        return fetchData(Decline(params))
    }
}
