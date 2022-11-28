//
//  Distribute.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation

final class Distribute: HTTPRequest, UD {
    typealias ResponseType = DistributeResult
    var params: [String : Any]?
    var path: String = "distribute"
    
    init(encodedShare: String, reciverVault: Vault, description: String, type: SecretDistributionType) {
        guard let user = mainVault else { return }
        
        let secretMessage = EncryptedMessage(receiver: reciverVault, encryptedText: encodedShare)
        
        let metaPasswordId = MetaPasswordId(name: description)
        // RustTransporterManager().generateMetaPassId(description: description)!
        print(metaPasswordId)
        let metaPasswordDoc = MetaPasswordDoc(id: metaPasswordId, vault: user)
        let metaPassword = MetaPasswordRequest(userSig: user, metaPassword: metaPasswordDoc)
        
        self.params = [
            "distributionType": type.rawValue,
            "metaPassword": metaPassword,
            "secretMessage": secretMessage
        ]
    }
}

struct DistributeResult: Codable {
    var status: String
}

enum SecretDistributionType: String, Codable {
    case Split
    case Recover
}

struct MetaPasswordRequest: Codable {
    var userSig: Vault
    var metaPassword: MetaPasswordDoc
}

struct EncryptedMessage: Codable {
    var receiver: Vault
    var encryptedText: String
}

struct MetaPasswordDoc: Codable {
    var id: MetaPasswordId
    var vault: Vault
}

struct MetaPasswordId: Codable {
    var id: String?
    var salt: String?
    var name: String?
    
    init(name: String) {
        self.name = name
        self.salt = UUID().uuidString
        self.id = UUID().uuidString
    }
}
