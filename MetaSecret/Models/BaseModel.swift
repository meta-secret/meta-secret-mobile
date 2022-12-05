//
//  BaseModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 02.12.2022.
//

import Foundation

protocol BaseModel: Codable, UD, JsonSerealizable {
    func toJson() -> String
}

extension BaseModel {
    func toJson() -> String {
        return jsonStringGeneration(from: self) ?? "{}"
    }
}
