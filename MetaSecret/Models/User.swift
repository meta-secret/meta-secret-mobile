//
//  User.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation

final class User: Codable {
    let userName: String
    let publicKey: Data
    let privateKey: Data
    private(set) var signature: Data?
    
    init(userName: String, publicKey: Data, privateKey: Data, signature: Data? = nil) {
        self.userName = userName
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.signature = signature
    }
    
    func addSignature(_ signature: Data) {
        self.signature = signature
    }
}
