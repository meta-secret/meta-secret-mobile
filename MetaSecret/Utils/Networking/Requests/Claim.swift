//
//  Claim.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.11.2022.
//

import Foundation

final class Calim: HTTPRequest, UD {
    typealias ResponseType = ClaimResult
    var params: [String : Any]?
    var path: String = "claimForPasswordRecovery"
    
    init(provider: Vault, secret: Secret) {
        guard let mainVault else { return }
        
        self.params = [
            "id": secret.secretID,
            "consumer": mainVault.createRequestJSon,
            "provider": provider.createRequestJSon
        ]
    }
}

#warning("Common Answer Needed")
struct ClaimResult: Codable {
    var status: String?
}

enum StatusResponse: String, Codable {
    case ok = "Ok"
    case err = "Error"
}
