//
//  AddSecretViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation
import UIKit

protocol AddSecretProtocol {
    func close()
}

final class AddSecretViewModel: Alertable, UD, Routerable, Signable {
    //MARK: - PROPERTIES
    enum Config {
        static let minMembersCount = 3
    }
    
    private var delegate: AddSecretProtocol? = nil
    private var components: [PasswordShare] = [PasswordShare]()
    private var vaults: [Vault]? = nil
    private var activeVaults: [Vault]? = nil
    private var description: String = ""
    
    var isMinMembers: Bool {
        return vaults?.count == Config.minMembersCount
    }
    
    //MARK: - INIT
    init(delegate: AddSecretProtocol) {
        self.delegate = delegate
    }
    
    //MARK: - PUBLIC METHODS
    func getVault(completion: (()->())?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Common.waitingTime, execute: { [weak self] in
            
            GetVault().execute() { [weak self] result in
                switch result {
                case .success(let result):
                    self?.vaults = result.vault?.signatures
                    self?.vaults?.append(contentsOf: self?.additionalUsers ?? [])
                    if self?.isMinMembers ?? false {
                        self?.activeVaults = self?.vaults
                    }
                    completion?()
                case .failure(let error):
                    completion?()
                    self?.hideLoader()
                    self?.showCommonError(error.localizedDescription)
                }
            }
            
        })
    }
    
    func split(secret: String, description: String, callBack: ((Bool)->())?) {
        self.description = description
        components = RustTransporterManager().split(secret: secret)
        callBack?(true)
    }
    
    func encode(callBack: (()->())?) {
        if let _ = readMySecret(description: "\(self.description)_\(mainVault?.vaultName ?? "")") {
            let model = AlertModel(title: Constants.Errors.warning, message: Constants.AddSecret.alreadySavedMessage, okHandler:  { [weak self] in
                self?.encodeInternal(callBack: callBack)
            })
            showCommonAlert(model)
        } else {
            encodeInternal(callBack: callBack)
        }
    }
    
    //    func saveMySecret(part: String, description: String, isSplited: Bool, callBack: (()->())? = nil) {
    //        if let _ = DBManager.shared.readSecretBy(description: description) {
    //            let model = AlertModel(title: Constants.Errors.warning, message: Constants.AddSecret.alreadySavedMessage, okHandler:  { [weak self] in
    //
    //                self?.saveToDB(part: part, description: description, isSplited: isSplited, callBack: callBack)
    //            })
    //            showCommonAlert(model)
    //        } else {
    //            saveToDB(part: part, description: description, isSplited: isSplited, callBack: callBack)
    //        }
    //    }
    
    //    func showDeviceLists(callBack: ((Bool)->())?) {
    //        let model = SceneSendDataModel(mainStringValue: description, shares: components, callBack: { [weak self] isSuccess in
    //            callBack?(isSuccess ?? false)
    //        })
    //        routeTo(.selectDevice, presentAs: .present, with: model)
    //    }
    //    func restoreSecret(completion: ((String)->())?) {
    //        completion?("")
    //    }
}

private extension AddSecretViewModel {
    
    //MARK: - WORK WITH DB
    func encodeInternal(callBack: (()->())?) {
        guard let keyManager = mainUser?.keyManager, let activeVaults else {
            showCommonError(nil)
            callBack?()
            return
        }
        
        for index in 0..<activeVaults.count {
            let vault = activeVaults[index]
            let shareToEncode = EncodeShare(senderKeyManager: keyManager, receiversPubKeys: vault.transportPublicKey?.base64Text ?? "", secret: components[index].shareBlocks?.first?.data?.base64Text ?? "")
            guard let encodedShare = RustTransporterManager().encode(share: shareToEncode) else {
                showCommonError(nil)
                callBack?()
                return
            }
            
            if (vault.device?.deviceId == mainVault?.device?.deviceId || (vault.isVirtual ?? false)) {
                let description = "\(self.description)_\(vault.vaultName)"
                saveToDB(share: encodedShare, description: description)
            } else {
                Distribute(encodedShare: encodedShare, reciverVault: vault, type: .Split).execute() { [weak self] result in
                    print("")
                }
            }
        }
        
        callBack?()
    }
    
    private func saveToDB(share: String, description: String) {
        let secret = Secret()
        secret.secretID = description
        secret.secretPart = share
        
        DBManager.shared.saveSecret(secret)
    }
    
    func readMySecret(description: String) -> Secret? {
        return DBManager.shared.readSecretBy(description: description)
    }
}
