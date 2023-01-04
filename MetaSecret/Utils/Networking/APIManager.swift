//
//  APIManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 02.01.2023.
//

import Foundation
import PromiseKit

protocol APIManagerProtocol {
    func fetchData<T>(_ endpoint: any HTTPRequest) -> Promise<T> where T : Decodable
}

class APIManager: NSObject, APIManagerProtocol {
    static let develop = "http://api.meta-secret.org/"
    
    private(set) var jsonManager: JsonSerealizable
    private(set) var userService: UsersServiceProtocol
    private(set) var rustManager: RustProtocol
    
    init(jsonManager: JsonSerealizable, userService: UsersServiceProtocol, rustManager: RustProtocol) {
        self.userService = userService
        self.jsonManager = jsonManager
        self.rustManager = rustManager
    }
    
    func fetchData<T>(_ endpoint: any HTTPRequest) -> Promise<T> where T : Decodable {
        return Promise { seal in
            guard let link = URL(string: APIManager.develop + endpoint.path) else {
                seal.reject(MetaSecretErrorType.networkError)
                return
            }
            
            var request = URLRequest(url: link)
            request.httpMethod = endpoint.method.rawValue
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let data = try? JSONSerialization.data(withJSONObject: endpoint.params, options: [])
            request.httpBody = data

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    seal.reject(error)
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let object = try decoder.decode(T.self, from: data)
                        seal.fulfill(object)
                    } catch {
                        seal.reject(error)
                    }
                } else {
                    seal.reject(NSError(domain: "NetworkLayer", code: 0, userInfo: nil))
                }
            }
            task.resume()
        }
    }
    
    
}
