//
//  EncodeShare.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 06.11.2022.
//

import Foundation

final class EncodeShare: Codable {
    var senderKeyManager: SerializedKeyManager
    var receiversPubKeys: String
    var secret: String
    
    init(senderKeyManager: SerializedKeyManager, receiversPubKeys: String, secret: String) {
        self.senderKeyManager = senderKeyManager
        self.receiversPubKeys = receiversPubKeys
        self.secret = secret
    }
}
