//
//  Decline.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation

final class Decline: HTTPRequest {
    var params: String
    var path: String { return "decline" }
    
    init(_ params: String) {
        self.params = params
    }
}
