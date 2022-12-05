//
//  UserSignature.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 02.12.2022.
//

import Foundation

final class UserSignature: BaseModel {
    var vaultName: String
    var signature: Base64EncodedText
    var publicKey: Base64EncodedText
    var transportPublicKey: Base64EncodedText
    var device: Device
    
    init(vaultName: String, signature: Base64EncodedText, publicKey: Base64EncodedText, transportPublicKey: Base64EncodedText, device: Device) {
        self.vaultName = vaultName
        self.signature = signature
        self.publicKey = publicKey
        self.transportPublicKey = transportPublicKey
        self.device = device
    }
}
