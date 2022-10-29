//
//  MetaSecretCoreWrapper.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 19.10.2022.
//

import Foundation

//MARK: - Key Manager
class KeysPairsWrapper {
    private let raw: OpaquePointer

    init() {
        raw = new_keys_pair()
    }

    deinit {
        keys_pair_destroy(raw)
    }

    var transportPubKey: String? {
        let byteSlice = get_transport_pub(raw)
        return byteSlice.asString()
    }

    var transportSecKey: String? {
        let byteSlice = get_transport_sec(raw)
        return byteSlice.asString()
    }
    
    var dsaPubKey: String? {
        let byteSlice = get_dsa_pub(raw)
        return byteSlice.asString()
    }

    var dsaKeyPair: String? {
        let byteSlice = get_dsa_key_pair(raw)
        return byteSlice.asString()
    }
}

//MARK: - Send to Rust Lib

class RustTransporterManager {
    func encodeString() -> String {
        let sender = KeysPairsWrapper()
        let receiverOne = KeysPairsWrapper()
        let receiverTwo = KeysPairsWrapper()
        
        var jsonDict = [String: Any]()
        jsonDict["senderDsaKeyPair"] = sender.dsaKeyPair
        jsonDict["senderDsaPubKey"] = sender.dsaPubKey
        jsonDict["senderTransportSecKey"] = sender.transportSecKey
        jsonDict["senderTransportPubKey"] = sender.transportPubKey
        jsonDict["receiversPubKeys"] = [sender.transportPubKey, receiverOne.transportPubKey, receiverTwo.transportPubKey]
        jsonDict["secret"] = "LA LA LA"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let jsonString = String(data: jsonData ?? Data(), encoding: String.Encoding.ascii)
        
        let jsonStringData = [UInt8](Data((jsonString ?? "").utf8))
        let resultJson = (split_and_encode(jsonStringData, jsonStringData.count)).asString() ?? ""
        
        return resultJson
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
