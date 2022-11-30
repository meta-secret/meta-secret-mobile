//
//  AeadCipherText.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 28.11.2022.
//

import Foundation

struct AeadCipherText: Codable {
    var msg: Base64EncodedText
    var authData: AeadAuthData
}

struct AeadAuthData: Codable {
    var associatedData: String
    var channel: CommunicationChannel
    var nonce: Base64EncodedText
}

struct CommunicationChannel: Codable {
    var sender: Base64EncodedText
    var receiver: Base64EncodedText
}
