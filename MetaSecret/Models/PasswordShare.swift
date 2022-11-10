//
//  PasswordShare.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 04.11.2022.
//

import Foundation

final class PasswordShares: Codable {
    var result: [PasswordShare]
}

final class PasswordShare: Codable {
    var shareId: Int?
    var shareBlocks: [ShareBlock]?
    
    enum CodingKeys: String, CodingKey {
        case shareId = "share_id"
        case shareBlocks = "share_blocks"
    }
}

final class ShareBlock: Codable {
    var block: Int?
    var config: ShareBlockConfig?
    var meta_data: ShareBlockMetaData?
    var data: ShareBlockData?
}

final class ShareBlockConfig: Codable {
    var number_of_shares: Int?
    var threshold: Int?
}

final class ShareBlockMetaData: Codable {
    var size: Int?
}

final class ShareBlockData: Codable {
    var base64Text: String?
}
