//
//  Decline.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation

class Decline: HTTPRequest {
    typealias ResponseType = Vault
    var params: [String : Any]?
    var path: String = "decline"
    
    init(member: User, candidate: User) {
        self.params = ["member": ["vaultName": member.userName,
                                  "publicKey": member.publicKey.base64EncodedString(),
                                  "rsaPublicKey": member.publicRSAKey.base64EncodedString(),
                                  "signature": member.signature?.base64EncodedString() ?? ""],
                       "candidate": ["vaultName": candidate.userName,
                                     "publicKey": candidate.publicKey.base64EncodedString(),
                                     "rsaPublicKey": candidate.publicRSAKey.base64EncodedString(),
                                     "signature": candidate.signature?.base64EncodedString() ?? ""]]
    }
}
