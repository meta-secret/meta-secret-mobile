//
//  ShareAPIService.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 02.01.2023.
//

import Foundation
import PromiseKit

protocol ShareAPIProtocol {
    func findShares() -> Promise<FindSharesResult>
    func distribute(encodedShare: AeadCipherText,
                    receiver: UserSignature,
                    description: String,
                    type: SecretDistributionType) -> Promise<DistributeResult>
    func requestClaim(provider: UserSignature, secret: Secret) -> Promise<ClaimResult>
    func findClaims() -> Promise<FindClaimsResult>
}

class ShareAPIService: APIManager, ShareAPIProtocol {
    func distribute(encodedShare: AeadCipherText,
                    receiver: UserSignature,
                    description: String,
                    type: SecretDistributionType) -> Promise<DistributeResult> {
        
        guard let mainVault = userService.mainVault,
              let userSignature = userService.userSignature,
              let metaPasswordId = rustManager.generateMetaPassId(description: description)
        else { return Promise(error: MetaSecretErrorType.userSignatureError) }
            
        let secretMessage = EncryptedMessage(receiver: receiver, encryptedText: encodedShare)
        let metaPasswordDoc = MetaPasswordDoc(id: metaPasswordId, vault: mainVault)
        let metaPasswordRequest = MetaPasswordRequest(userSig: userSignature, metaPassword: metaPasswordDoc)
        let request = DistributeRequest(distributionType: type.rawValue,
                                        metaPassword: metaPasswordRequest,
                                        secretMessage: secretMessage)
        
        guard let params = jsonManager.jsonStringGeneration(from: request) else {
            return Promise(error: MetaSecretErrorType.objectToJson)
        }

        return fetchData(Distribute(params))
    }
    
    func findShares() -> Promise<FindSharesResult> {
        guard
            let userSignature = userService.userSignature,
            let params = jsonManager.jsonStringGeneration(from: userSignature)
        else {
            return Promise(error: MetaSecretErrorType.userSignatureError)
        }
        
        return fetchData(FindShares(params))
    }
    
    func requestClaim(provider: UserSignature, secret: Secret) -> Promise<ClaimResult> {
        guard
            let userSignature = userService.userSignature,
            let metaPasswordId = rustManager.generateMetaPassId(description: secret.secretName)
        else {
            return Promise(error: MetaSecretErrorType.userSignatureError)
        }
        
        let request = PasswordRecoveryRequest(id: metaPasswordId,
                                              consumer: userSignature,
                                              provider: provider)

        guard let params = jsonManager.jsonStringGeneration(from: request) else {
            return Promise(error: MetaSecretErrorType.objectToJson)
        }

        return fetchData(Claim(params))
    }
    
    func findClaims() -> Promise<FindClaimsResult> {
        guard
            let userSignature = userService.userSignature,
            let params = jsonManager.jsonStringGeneration(from: userSignature)
        else {
            return Promise(error: MetaSecretErrorType.userSignatureError)
        }
        
        return fetchData(FindClaims(params))
    }
    
}

