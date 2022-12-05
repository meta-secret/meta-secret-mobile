//
//  HTTPRequest.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

protocol HTTPRequest {
    associatedtype ResponseType: Codable
    var path: String { get }
    var method: HTTPMethod { get }
    var params: String { get set }
}

extension HTTPRequest {
    var method: HTTPMethod {
        get {
            return HTTPMethod.post
        }
    }
    var params: String {
        get {
            return "{}"
        }
    }
    
    func execute (dispatcher: HTTPDispatcher = URLSessionNetworkDispatcher.instance, completionHandler: @escaping (Result<ResponseType, HTTPStatusCode>) -> Void) {
        
        dispatcher.dispatch(path: path, method: method, params: self.params) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    print(json ?? [:])
                    
                    if let decoded = try? JSONDecoder().decode(ResponseType.self, from: data) {
                        completionHandler(.success(decoded))
                    } else {
                        if let e = EmptyClass() as? ResponseType {
                            completionHandler(.success(e))
                        } else {
                            do {
                                let res = try JSONDecoder().decode(ResponseType.self, from: data)
                                completionHandler(.success(res))
                            } catch let _e {
                                print(_e)
                                completionHandler(.failure(.FailedToDecode))
                            }
                        }
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
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
