//
//  Distribute.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation

final class Distribute: HTTPRequest {
    var params: String
    var path: String { return "distribute" }
    
    init(_ params: String) {
        self.params = params
    }
}

struct DistributeResult: Codable {
    var msgType: String
    var data: String?
    var error: String?
}

enum SecretDistributionType: String, Codable {
    case split
    case recover
}

final class DistributeRequest: BaseModel {
    let distributionType: String
    let metaPassword: MetaPasswordRequest
    let secretMessage: EncryptedMessage
    
    init(distributionType: String, metaPassword: MetaPasswordRequest, secretMessage: EncryptedMessage) {
        self.distributionType = distributionType
        self.metaPassword = metaPassword
        self.secretMessage = secretMessage
    }
}

final class MetaPasswordRequest: BaseModel {
    var userSig: UserSignature
    var metaPassword: MetaPasswordDoc
    
    init(userSig: UserSignature, metaPassword: MetaPasswordDoc) {
        self.userSig = userSig
        self.metaPassword = metaPassword
    }
}

final class EncryptedMessage: BaseModel {
    var receiver: UserSignature
    var encryptedText: AeadCipherText
    
    init(receiver: UserSignature, encryptedText: AeadCipherText) {
        self.receiver = receiver
        self.encryptedText = encryptedText
    }
}

final class MetaPasswordDoc: BaseModel {
    var id: MetaPasswordId
    var vault: VaultDoc
    
    init(id: MetaPasswordId, vault: VaultDoc) {
        self.id = id
        self.vault = vault
    }
}

final class MetaPasswordId: BaseModel {
    var id: String?
    var salt: String?
    var name: String?
    
    init(name: String) {
        self.name = name
        self.salt = UUID().uuidString
        self.id = UUID().uuidString
    }
}
