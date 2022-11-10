//
//  Distribute.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation

class Distribute: HTTPRequest, UD {
    typealias ResponseType = DistributeResult
    var params: [String : Any]?
    var path: String = "distribute"
    
    init(encodedShare: String, reciverVault: Vault, type: SecretDistributionType) {
        guard let user = mainVault else { return }
        
//        let secretMessage = EncryptedMessage(receiver: reciverVault, encryptedText: encryptedShare)
//        let passwordRequest = MetaPasswordRequest(userSig: user, metaPassword: <#T##<<error type>>#>)
//
//        self.params = [
//            "distributionType": type.rawValue,
//            "metaPassword": password,
//            "secretMessage": secretMessage
//        ]
    }
}

struct DistributeResult: Codable {
    var status: String
}

enum SecretDistributionType: String {
    case Split
    case Recover
}

//struct MetaPasswordRequest: Codable {
//    let userSig: Vault
//    let metaPassword: MetaPasswordDoc,
//}

struct EncryptedMessage: Codable {
    var receiver: Vault
    var encryptedText: String
}


