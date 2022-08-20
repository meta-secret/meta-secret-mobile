//
//  LoginSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit
import CryptoKit

protocol LoginSceneProtocol {
    func showAlert(error: String?)
}

final class LoginSceneViewModel: Signable {
    private var user: User? = nil
    private var vault: Vault? = nil
    private var delegate: LoginSceneProtocol? = nil
    
    //MARK: - INIT
    init(delegate: LoginSceneProtocol) {
        self.delegate = delegate
    }
    
    //MARK: - REGISTRATION
    func register(user: User) {
        Register(vaultName: user.userName, publicKey: user.publicKey.base64EncodedString(), signature: (user.signature ?? Data()).base64EncodedString()).execute() { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == .Registered {
                    self?.getVault()
                } else {
                    //TODO: Check and accept
                }
            case .failure(let error):
                self?.delegate?.showAlert(error: error.localizedDescription)
            }
        }
    }
}

private extension LoginSceneViewModel {
    //MARK: - GETTING VAULT
    func getVault() {
        GetVault(signature: (user?.signature ?? Data()).base64EncodedString()).execute() { [weak self] result in
            switch result {
            case .success(let vault):
                print(vault)
            case .failure(let error):
                self?.delegate?.showAlert(error: error.localizedDescription)
            }
        }
    }
}
        
