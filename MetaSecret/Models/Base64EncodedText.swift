//
//  Base64EncodedText.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 17.11.2022.
//

import Foundation

final class Base64EncodedText: BaseModel, Equatable {
    var base64Text: String
    
    static func == (lhs: Base64EncodedText, rhs: Base64EncodedText) -> Bool {
        return lhs.base64Text == rhs.base64Text
    }
}
