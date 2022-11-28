//
//  FindClaims.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 23.11.2022.
//

import Foundation

final class FindCalim: HTTPRequest, UD {
    typealias ResponseType = [PasswordRecoveryRequest]
    var params: [String : Any]?
    var path: String = "findPasswordRecoveryClaims"
    
    init() {
        guard let mainVault else { return }
        
        self.params = mainVault.createRequestJSon()
    }
}

struct PasswordRecoveryRequest: Codable {
    var id: MetaPasswordId?
    var consumer: Vault?
    var provider: Vault?
}
