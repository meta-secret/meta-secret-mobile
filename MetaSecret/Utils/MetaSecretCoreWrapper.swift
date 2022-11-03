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
    
    func encodeString() -> String {
        return "resultJson"
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
