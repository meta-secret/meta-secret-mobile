//
//  User.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit


struct UserSecurityBox: Codable {
    var signature: Base64EncodedText
    var keyManager: SerializedKeyManager
}

struct SerializedKeyManager: Codable {
    var dsa: SerializedDsaKeyPair
    var transport: SerializedTransportKeyPair
}

struct SerializedDsaKeyPair: Codable {
    var keyPair: Base64EncodedText
    var publicKey: Base64EncodedText
}

struct SerializedTransportKeyPair: Codable {
    var secretKey: Base64EncodedText
    var publicKey: Base64EncodedText
}
