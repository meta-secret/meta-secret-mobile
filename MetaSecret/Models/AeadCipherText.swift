//
//  AeadCipherText.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 28.11.2022.
//

import Foundation

final class AeadCipherText: BaseModel {
    var msg: Base64EncodedText
    var authData: AeadAuthData
    
    init(msg: Base64EncodedText, authData: AeadAuthData) {
        self.msg = msg
        self.authData = authData
    }
}

final class AeadAuthData: BaseModel {
    var associatedData: String
    var channel: CommunicationChannel
    var nonce: Base64EncodedText
    
    init(associatedData: String, channel: CommunicationChannel, nonce: Base64EncodedText) {
        self.associatedData = associatedData
        self.channel = channel
        self.nonce = nonce
    }
}

final class CommunicationChannel: BaseModel {
    var sender: Base64EncodedText
    var receiver: Base64EncodedText
    
    init(sender: Base64EncodedText, receiver: Base64EncodedText) {
        self.sender = sender
        self.receiver = receiver
    }
}
