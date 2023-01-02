//
//  CommonResponse.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 30.12.2022.
//


struct CommonResponse: Codable {
    var msgType: String
    var data: String?
    var error: String?
}
