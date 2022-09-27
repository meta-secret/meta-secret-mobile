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
    private lazy var secret = Secret()
    
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
        guard let name = mainUser?.userName, let key = mainUser?.publicRSAKey else { return }
        let encryptedPartOfCode = encryptData(Data(part.utf8), key: key, name: name)

        self.description = description
        
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

    func showDeviceLists() {
        guard let component = components.first else { return }
        let model = SceneSendDataModel(mainStringValue: description, stringValue: component, callBack: { [weak self] isSuccess in
            
            let secret = Secret()
            secret.secretID = self?.secret.secretID ?? ""
            secret.secretPart = self?.secret.secretPart
            secret.isFullySplited = true
            secret.isSavedLocaly = false

            DBManager.shared.saveSecret(secret)

            self?.delegate?.close()
        })
        routeTo(.selectDevice, presentAs: .present, with: model)
    }
}
