//
//  Claim.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.11.2022.
//

import Foundation

final class Claim: HTTPRequest {
    init(provider: UserSignature, secret: Secret) {
        super.init()
        path = "claimForPasswordRecovery"
        guard let userSignature = userService.userSignature else { return }
        guard let metaPasswordId = rustManager.generateMetaPassId(description: secret.secretName) else { return }
        
        let request = PasswordRecoveryRequest(id: metaPasswordId,
                                              consumer: userSignature,
                                              provider: provider)
        
        self.params = jsonService.jsonStringGeneration(from: request) ?? "{}"
    }
}

//struct ClaimResult: Codable {
//    var msgType: String?
//    var data: String?
//    var error: String?
//}

enum StatusResponse: String, Codable {
    case ok = "Ok"
    case err = "Error"
}

final class PasswordRecoveryRequest: BaseModel {
    let id: MetaPasswordId
    let consumer: UserSignature
    let provider: UserSignature
    
    init(id: MetaPasswordId, consumer: UserSignature, provider: UserSignature) {
        self.id = id
        self.consumer = consumer
        self.provider = provider
    }
}
