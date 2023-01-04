//
//  HTTPRequest.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

protocol HTTPRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var params: String { get set }
}

extension HTTPRequest {
    var path: String {
        get {
            return ""
        }
    }
    
    var method: HTTPMethod {
        get {
            return .post
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
