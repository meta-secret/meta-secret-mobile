//
//  MetaSecretCoreWrapper.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 19.10.2022.
//

import Foundation

//MARK: - Send to Rust Lib
class RustTransporterManager {
    func generate(for name: String) -> UserSignature? {
        let userSignature = UserSignature()
        userSignature.vaultName = name
        let json = JsonManger.jsonU8Generation(from: userSignature)
        
        let signedUserJson = generate_signed_user(json, json.count).asString() ?? ""
        do {
            let signature: UserSignature = try JsonManger.object(from: signedUserJson)
            return signature
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func split(secret: String) -> [PasswordShare] {
        var components = [PasswordShare]()
        
        let secretData = [UInt8](Data(secret.utf8))
        let jsonResult = split_secret(secretData, secretData.count)
        guard let jsonString = jsonResult.asString() else { return []}
        do {
            components = try JsonManger.array(from: jsonString)
        } catch {
            print(error.localizedDescription)
            return []
        }
        return components
    }
    
    func encode(share: EncodeShare) -> String? {
        let jsonData = JsonManger.jsonU8Generation(from: share)
        let result = encode_secret(jsonData, jsonData.count).asString()
        return result
    }
}

//MARK: - String translator
extension RustByteSlice {
    func asUnsafeBufferPointer() -> UnsafeBufferPointer<UInt8> {
        return UnsafeBufferPointer(start: bytes, count: len)
    }

    func asString(encoding: UInt = NSUTF8StringEncoding) -> String? {
        return String(bytes: asUnsafeBufferPointer(), encoding: String.Encoding(rawValue: encoding))
    }
}
