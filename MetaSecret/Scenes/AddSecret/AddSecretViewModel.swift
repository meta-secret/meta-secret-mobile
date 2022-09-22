//
//  AddSecretViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation
import UIKit

protocol AddSecretProtocol {}

final class AddSecretViewModel: Alertable, UD, Routerable, Signable {
    //MARK: - PROPERTIES
    enum Config {
        static let minMembersCount = 3
    }
    
    private var delegate: AddSecretProtocol? = nil
    private var components: [String] = [String]()
    
    //MARK: - INIT
    init(delegate: AddSecretProtocol) {
        self.delegate = delegate
    }
    
    //MARK: - PUBLIC METHODS
    func saveMySecret(part: String, description: String, callBack: (()-())? = nil) {
        guard let name = mainUser?.userName, let key = mainUser?.publicRSAKey, let myPartOfSecret = components.first else { return }
        let encryptedPartOfCode = encryptData(Data(myPartOfSecret.utf8), key: key, name: name)

        let secret = Secret()
        secret.secretID = description
        secret.secretPart = encryptedPartOfCode

        DBManager.shared.saveSecret(secret)
        components.removeFirst()
//        
//        routeTo(.selectDevice, presentAs: .present, with: (note, components))
    }
    
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
    
    func split(secret: String, description: String) {
        let pass = secret
        let count = pass.count / 3
        
        components = pass.components(withMaxLength: count)
        
        guard let firstPart = components.first else {
            showCommonError(nil)
            return
        }
        saveMySecret(part: firstPart, description: description)
    }
}

private extension AddSecretViewModel {
    func showDeviceLists() {
        
    }
}
