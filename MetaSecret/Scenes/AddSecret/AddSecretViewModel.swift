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
    private var components: [String] = [String]()
    private var description: String = ""
    
    //MARK: - INIT
    init(delegate: AddSecretProtocol) {
        self.delegate = delegate
    }
    
    //MARK: - PUBLIC METHODS
    func getVault(completion: ((Bool)->())?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Common.waitingTime, execute: { [weak self] in
            
            GetVault().execute() { [weak self] result in
                switch result {
                case .success(let result):
                    let membersCount = result.vault?.signatures?.count ?? 0
                    if membersCount < Config.minMembersCount {
                        completion?(false)
                    } else {
                        completion?(true)
                    }
                case .failure(let error):
                    self?.hideLoader()
                    self?.showCommonError(error.localizedDescription)
                }
            }
            
        })
    }
    
    func saveMySecret(part: String, description: String, isSplited: Bool, callBack: (()->())? = nil) {
        if let _ = DBManager.shared.readSecretBy(description: description) {
            let model = AlertModel(title: Constants.Errors.warning, message: Constants.AddSecret.alreadySavedMessage, okHandler:  { [weak self] in
                
                self?.saveToDB(part: part, description: description, isSplited: isSplited, callBack: callBack)
            })
            showCommonAlert(model)
        } else {
            saveToDB(part: part, description: description, isSplited: isSplited, callBack: callBack)
        }
    }
    
    func readMySecret(description: String) -> String? {
        guard let name = mainUser?.vaultName, let key = mainUser?.keyManager?.transport.secretKey else { return nil }
        guard let secret = DBManager.shared.readSecretBy(description: description) else { return nil }
        guard let encryptedSecret = secret.secretPart else { return nil }
        return ""// decryptData(encryptedSecret, key: key, name: name)
    }
    
    private func saveToDB(part: String, description: String, isSplited: Bool, callBack: (()->())? = nil) {
        guard let name = mainUser?.name(), let key = mainUser?.publicKey() else { return }
        let encryptedPartOfCode = Data() //encryptData(Data(part.utf8), key: key, name: name)
        
        self.description = description
        
        let secret = Secret()
        secret.secretID = description
        secret.secretPart = encryptedPartOfCode
        secret.isSavedLocaly = !isSplited
        
        DBManager.shared.saveSecret(secret)
        
        callBack?()
    }
    
    func split(secret: String, description: String, callBack: ((Bool)->())?) {
        //TODO: REPLACE FROM HERE
        let pass = secret
        let count = pass.count / 3
        
        components = pass.components(withMaxLength: count)
        
        guard let firstPart = components.first else {
            showCommonError(nil)
            return
        }
        
        //TODO: REPLACE TO HERE
        
        saveMySecret(part: firstPart, description: description, isSplited: true) { [weak self] in
            self?.components.removeFirst()
            callBack?(true)
        }
    }
    
    func restoreSecret(completion: ((String)->())?) {
        completion?("")
    }

    func showDeviceLists(callBack: ((Bool)->())?) {
        let model = SceneSendDataModel(mainStringValue: description, stringArray: components, callBack: { [weak self] isSuccess in
            callBack?(isSuccess ?? false)
        })
        routeTo(.selectDevice, presentAs: .present, with: model)
    }
}
