//
//  Distribute.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation

final class Distribute: HTTPRequest {
    init(encodedShare: AeadCipherText, receiver: UserSignature, description: String, type: SecretDistributionType) {
        super.init()
        path = "distribute"
        
        guard let mainVault = userService.mainVault else { return }
        guard let userSignature = userService.userSignature else { return }
        
        let secretMessage = EncryptedMessage(receiver: receiver, encryptedText: encodedShare)

        guard let metaPasswordId = rustManager.generateMetaPassId(description: description) else { return }
        let metaPasswordDoc = MetaPasswordDoc(id: metaPasswordId, vault: mainVault)
        let metaPasswordRequest = MetaPasswordRequest(userSig: userSignature, metaPassword: metaPasswordDoc)

        let request = DistributeRequest(distributionType: type.rawValue,
                                        metaPassword: metaPasswordRequest,
                                        secretMessage: secretMessage)
        
        self.params = jsonService.jsonStringGeneration(from: request) ?? "{}"
    }
}

//struct DistributeResult: Codable {
//    var msgType: String
//    var data: String?
//    var error: String?
//}

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
