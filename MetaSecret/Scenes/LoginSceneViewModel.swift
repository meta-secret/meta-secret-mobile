//
//  LoginSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit
import CryptoKit

protocol LoginSceneProtocol {}

final class LoginSceneViewModel: Signable, Alertable {
    private var user: User? = nil
    private var vault: Vault? = nil
    private var delegate: LoginSceneProtocol? = nil
    
    //MARK: - INIT
    init(delegate: LoginSceneProtocol) {
        self.delegate = delegate
    }
    
    //MARK: - REGISTRATION
    func register(_ userName: String) {
        guard let user = generateKeys(for: userName) else {
            showCommonError(nil)
            return
        }
        signData(user.publicKey, for: user)
        
        Register(vaultName: user.userName, publicKey: user.publicKey.base64EncodedString(), signature: (user.signature ?? Data()).base64EncodedString()).execute() { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == .Registered {
                    self?.getVault(user: user)
                } else {
                    //TODO: Check and accept
                }
            case .failure(let error):
                self?.showCommonError(error.localizedDescription)
            }
        }
    }
    
    //MARK: - ALERTS
    func showAlert(title: String = Constants.Errors.error, message: String = Constants.Errors.swwError) {
        let alertModel = AlertModel(title: Constants.Errors.error, message: Constants.Errors.enterName)
        showCommonAlert(alertModel)
    }
}

private extension LoginSceneViewModel {
    //MARK: - GETTING VAULT
    func getVault(user: User) {
        GetVault(vaultName: user.userName, publicKey: user.publicKey.base64EncodedString(), signature: (user.signature ?? Data()).base64EncodedString()).execute() { [weak self] result in
            switch result {
            case .success(let vault):
                print(vault)
            case .failure(let error):
                self?.showCommonError(error.localizedDescription)
            }
        }
    }
}
        
