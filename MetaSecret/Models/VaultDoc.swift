//
//  Vault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation

final class VaultDoc: BaseModel {
    var vaultName: String
    var declinedJoins: [UserSignature]?
    var pendingJoins: [UserSignature]?
    var signatures: [UserSignature]?
    
    init(vaultName: String, declinedJoins: [UserSignature]? = nil, pendingJoins: [UserSignature]? = nil, signatures: [UserSignature]? = nil) {
        self.vaultName = vaultName
        self.declinedJoins = declinedJoins
        self.pendingJoins = pendingJoins
        self.signatures = signatures
    }
}
