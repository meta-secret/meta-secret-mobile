//
//  HTTPRequest.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

protocol HTTPRequestProtocol {
    associatedtype ResponseType: Codable
    var path: String { get set }
    var method: HTTPMethod { get set }
    var params: String { get set }
    
    func execute(dispatcher: HTTPDispatcher, completionHandler: @escaping (Result<ResponseType, HTTPStatusCode>) -> Void)
}

class HTTPRequest: NSObject, HTTPRequestProtocol {
    private(set) var jsonService: JsonSerealizable
    private(set) var userService: UsersServiceProtocol
    private(set) var rustManager: RustProtocol
    typealias ResponseType = CommonResponse
    
    override init(/*serService: UsersServiceProtocol*/) {
        #warning("Can't init be here")
        self.jsonService = JsonSerealizManager()
        self.rustManager = RustTransporterManager(dbManager: DBManager(), jsonSerializeManager: jsonService)
        self.userService = UsersService()
    }
    
    private var _params = "{}"
    private var _path = ""
    private var _method = HTTPMethod.post
    
    var path: String {
        get {
            return _path
        }
        set {
            _path = newValue
        }
    }
    
    var method: HTTPMethod {
        get {
            return _method
        }
        set {
            _method = newValue
        }
    }
    var params: String {
        get {
            return _params
        }
        set {
            _params = newValue
        }
    }
    
    func execute(dispatcher: HTTPDispatcher = URLSessionNetworkDispatcher.instance, completionHandler: @escaping (Result<ResponseType, HTTPStatusCode>) -> Void) {
        
        dispatcher.dispatch(path: path, method: method, params: self.params) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
//                    print(json ?? [:])
                    
                    if let decoded = try? JSONDecoder().decode(ResponseType.self, from: data) {
                        completionHandler(.success(decoded))
                    } else {
                        if let e = EmptyClass() as? ResponseType {
                            completionHandler(.success(e))
                        } else {
                            do {
                                let res = try JSONDecoder().decode(ResponseType.self, from: data)
                                completionHandler(.success(res))
                            } catch let e {
                                print("## dispatch = \(e)")
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
