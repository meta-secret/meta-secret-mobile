//
//  URLSessionNetworkDispatcher.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

struct Server {
//    static let develop = "http://localhost:8000/"
    static let develop = "http://api.meta-secret.org/"
//    static let develop = "http://api.meta-secret.org:8080/"
}

public struct URLSessionNetworkDispatcher: HTTPDispatcher, JsonSerealizable {
    
    func dispatch(path: String, method: HTTPMethod, params: String, completionHandler: @escaping (Result<Data, HTTPStatusCode>) -> Void) {
//        print("## Request PATH \(Server.develop)\(path)")
//        print("## Request JSonBody \(params)")
        guard let url = URL(string: "\(Server.develop)\(path)") else {
            completionHandler(.failure(HTTPStatusCode.InvalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        let body = Data(params.utf8)
        urlRequest.httpBody = body
//        print("## Request body \(String(decoding: body, as: UTF8.self))")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
//            print("## ‼️DATA \(String(decoding: data ?? Data(), as: UTF8.self)) ‼️")
            if error != nil {
                print("## ⚠️ \(error?.localizedDescription) ⚠️")
                completionHandler(.failure(HTTPStatusCode.Networking))
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                guard let error = HTTPStatusCode(rawValue: httpStatus.statusCode) else {
                    completionHandler(.failure(HTTPStatusCode.Unknown))
                    return
                }
                completionHandler(.failure(error))
                return
            }
            guard let _data = data else {
                completionHandler(.failure(HTTPStatusCode.NoData))
                return
            }
            completionHandler(.success(_data))
        }.resume()
    }
    
    public static let instance = URLSessionNetworkDispatcher()
    private init() {}
}

public enum HTTPStatusCode: Int, Error {
    case InvalidCredentials = 403
    case HardReject = 411
    case NotFound = 404
    case Unknown = 666
    case InvalidURL = 701
    case NoData = 702
    case FailedToDecode = 703
    case Networking = 704
    
    var localizedDescription: String {
        get {
            switch self {
            case .FailedToDecode:
                return "Failed to decode."
                
            case .Networking:
                return "Networking Error."
                
            case .NoData:
                return "No Data Received."
                
            case .InvalidURL:
                return "Invalid URL."
                
            case .Unknown:
                return "Unknown."
                
            case .NotFound:
                return "Not Found."
                
            case .HardReject:
                return "Access has been disabled by admin."
                
            case .InvalidCredentials:
                return "Invalid Credentials."
            }
        }
    }
}

public class EmptyClass: Codable {}
