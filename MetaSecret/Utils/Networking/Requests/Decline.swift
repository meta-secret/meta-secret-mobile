//
//  Decline.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation

class Decline: HTTPRequest, UD {
    typealias ResponseType = DeclineResult
    var params: [String : Any]?
    var path: String = "decline"
    
    init(candidate: Vault) {
        guard let member = mainUser else { return }
        
        self.params = ["member": ["vaultName": member.userName,
                                  "publicKey": member.publicKey.base64EncodedString(),
                                  "rsaPublicKey": member.publicRSAKey.base64EncodedString(),
                                  "signature": member.signature?.base64EncodedString() ?? ""],
                       "candidate": ["vaultName": candidate.vaultName,
                                     "publicKey": candidate.publicKey,
                                     "rsaPublicKey": candidate.rsaPublicKey,
                                     "signature": candidate.signature]]
    }
}

struct DeclineResult: Codable {
    var status: String?
}
