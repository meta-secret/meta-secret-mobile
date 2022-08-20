//
//  HTTPDispatcher.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

protocol HTTPDispatcher {
    func dispatch(path: String, method: HTTPMethod, params: [String: Any]?, completionHandler: @escaping (Result<Data, HTTPStatusCode>) -> Void)
}
