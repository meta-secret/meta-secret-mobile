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
    
    var isFullySplitted: Bool = false
    
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
                    self?.vaults?.removeAll()
                    self?.vaults = result.vault?.signatures
                    if self?.vaults?.count ?? 0 <= Constants.Common.neededMembersCount {
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
    
    func vaultsCount() -> Int {
        return vaults?.count ?? 0
    }
    
    func split(secret: String, description: String, callBack: ((Bool)->())?) {
        self.description = description
        
        if let _ = readMySecret(description: "\(self.description)") {
            let model = AlertModel(title: Constants.Errors.warning, message: Constants.AddSecret.alreadySavedMessage, okHandler:  { [weak self] in
                self?.splitInternal(secret, callBack: callBack)
            })
            showCommonAlert(model)
        } else {
            splitInternal(secret, callBack: callBack)
        }
    }
    
    func encodeAndDistribute(callBack: ((Bool)->())?) {
        #warning("!!!!")
    }
    
    func showDeviceLists(callBack: ((Bool)->())?) {
        let model = SceneSendDataModel(vaults: vaults, callBackVaults: { [weak self] vaults in
            self?.showLoader()
            self?.activeVaults = vaults
            self?.encodeAndDistribute(callBack: { isSuccess in
                callBack?(isSuccess)
            })
        })
        routeTo(.selectDevice, presentAs: .push, with: model)
    }
    
    func restoreSecret(_ description: String, callBack: ((String?)->())?) {
        #warning("!!!!")
    }
}

private extension AddSecretViewModel {
    func splitInternal(_ secret: String, callBack: ((Bool)->())?) {
        components = RustTransporterManager().split(secret: secret)
        callBack?(!components.isEmpty)
    }
    
    //MARK: - WORK WITH DB
    private func saveToDB(shares: [String], description: String, isVirtual: Bool) {
        let secret = Secret()
        secret.secretID = description
        secret.shares.append(objectsIn: shares)
        DBManager.shared.saveSecret(secret)
    }
    
    func readMySecret(description: String) -> Secret? {
        return DBManager.shared.readSecretBy(description: description)
    }
}
