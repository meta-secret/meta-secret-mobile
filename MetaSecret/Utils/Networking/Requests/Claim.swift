//
//  Claim.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.11.2022.
//

import Foundation

final class Claim: HTTPRequest, UD {
    typealias ResponseType = ClaimResult
    var params: String = "{}"
    var path: String = "claimForPasswordRecovery"
    
    init(provider: UserSignature, secret: Secret) {
        guard let userSignature else { return }
        guard let metaPasswordId = RustTransporterManager().generateMetaPassId(description: secret.secretName) else { return }
        
        let request = PasswordRecoveryRequest(id: metaPasswordId,
                                              consumer: userSignature,
                                              provider: provider)
        
        self.params = request.toJson()
    }
}

struct ClaimResult: Codable {
    var msgType: String?
    var data: String?
    var error: String?
}

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
