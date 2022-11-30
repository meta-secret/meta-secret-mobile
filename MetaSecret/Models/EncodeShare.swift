//
//  EncodeShare.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 06.11.2022.
//

import Foundation

final class ShareToEncrypt: Codable {
    var senderKeyManager: SerializedKeyManager
    var receiverPubKey: Base64EncodedText
    var secret: String
    
    init(senderKeyManager: SerializedKeyManager, receiverPubKey: Base64EncodedText, secret: String) {
        self.senderKeyManager = senderKeyManager
        self.receiverPubKey = receiverPubKey
        self.secret = secret
    }
}
