//
//  PasswordShare.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 04.11.2022.
//

import Foundation

struct UserShareDtos: Codable {
    var result: [UserShareDto]
}

final class UserShareDto: BaseModel {
    var shareId: Int
    var shareBlocks: [ShareBlock]
    
    enum CodingKeys: String, CodingKey {
        case shareId = "share_id"
        case shareBlocks = "share_blocks"
    }
    
    init(shareId: Int, shareBlocks: [ShareBlock]) {
        self.shareId = shareId
        self.shareBlocks = shareBlocks
    }
}

struct ShareBlock: Codable {
    var block: Int?
    var config: ShareBlockConfig?
    var meta_data: ShareBlockMetaData?
    var data: ShareBlockData?
}

struct ShareBlockConfig: Codable {
    var number_of_shares: Int?
    var threshold: Int?
}

struct ShareBlockMetaData: Codable {
    var size: Int?
}

struct ShareBlockData: Codable {
    var base64Text: String?
}
