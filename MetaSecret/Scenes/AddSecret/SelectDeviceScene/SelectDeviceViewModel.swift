//
//  SelectDeviceViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 07.09.2022.
//

import Foundation
import PromiseKit

protocol SelectDeviceProtocol {
    func reloadData(source: [UserSignature])
}

final class SelectDeviceViewModel: CommonViewModel {
    //MARK: - PROPERTIES
    var delegate: SelectDeviceProtocol? = nil
    
    //MARK: - INIT
    override init() {
        
    }
    
    override func loadData() -> Promise<Void> {
        return firstly {
            fetchAllDevices()
        }.asVoid()
    }
    
    //MARK: - PUBLIC METHODS
    func send(_ share: String, to member: UserSignature, with note: String, callback: (()->())?) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
            self?.sending(share, to: member, with: note, callback: callback)
        })
    }
}

private extension SelectDeviceViewModel {
    func fetchAllDevices() -> Promise<Void> {
//        GetVault().execute() { [weak self] result in
//            switch result {
//            case .success(let result):
//                guard result.msgType == Constants.Common.ok else {
//                    print(result.error ?? "")
//                    return
//                }
//
//                guard var members = result.data?.vault?.signatures else { return }
//                if let ownIndex = members.firstIndex(where: {$0.device.deviceId == self?.userSignature?.device.deviceId}) {
//                    members.remove(at: ownIndex)
//                }
//                self?.delegate?.reloadData(source: members)
//            case .failure(let error):
//                self?.showCommonError(error.localizedDescription)
//            }
//        }
        return Promise().asVoid()
    }
    
    func sending(_ share: String, to member: UserSignature, with note: String, callback: (()->())?) {
//        guard let key = member.securityBox?.keyManager.dsa.publicKey.base64Text.data(using: .utf8) else {
//            showCommonError(nil)
//            return
//        }
//        let name = member.vaultName
//        let encryptedPartOfCode = encryptData(Data(share.utf8), key: key, name: name)
//
//        let secret = Secret()
//        secret.secretID = note
//        secret.secretPart = encryptedPartOfCode
//
//        Distribute(encryptedShare: encryptedPartOfCode?.base64EncodedString() ?? "").execute() { [weak self] result in
//            switch result {
//            case .success(_):
//                break
//            case .failure(let error):
//                self?.showCommonError(error.localizedDescription)
//            }
//        }
    }
}
