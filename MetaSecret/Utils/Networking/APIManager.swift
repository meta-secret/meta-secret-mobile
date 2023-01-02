//
//  APIManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 02.01.2023.
//

import Foundation
import PromiseKit

protocol NetworLayerProtocl {
    func fetchData<T>(_ endpoint: HTTPRequestProtocol) -> Promise<T> where T : Decodable
    func fetchData(from url: URL) -> Promise<Data>
}

class APIManager {
    func fetchData(from url: URL) -> Promise<Data> {
        return Promise { seal in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    seal.reject(error)
                } else if let data = data {
                    seal.fulfill(data)
                } else {
                    seal.reject(NSError(domain: "NetworkLayer", code: 0, userInfo: nil))
                }
            }
            task.resume()
        }
    }

    func postData(to url: URL, with parameters: [String: Any]) -> Promise<Data> {
        return Promise { seal in
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = data

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    seal.reject(error)
                } else if let data = data {
                    seal.fulfill(data)
                } else {
                    seal.reject(NSError(domain: "NetworkLayer", code: 0, userInfo: nil))
                }
            }
            task.resume()
        }
    }
}
