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
    func resetTextField()
}

final class LoginSceneViewModel: Signable, Alertable, Routerable {
    private var delegate: LoginSceneProtocol? = nil
    
    //MARK: - INIT
    init(delegate: LoginSceneProtocol) {
        self.delegate = delegate
        checkStatus()
    }
    
    //MARK: - REGISTRATION
    func register(_ userName: String) {
        showLoader()
        if deviceStatus == .pending {
            showAwaitingAlert()
            hideLoader()
            return
        }
        
        guard let user = generateKeys(for: userName) else {
            showCommonError(nil)
            hideLoader()
            return
        }
        
        let userNameData = user.userName.data(using: .utf8) ?? Data()
        signData(userNameData, for: user)
        
        mainUser = user
        
        //TODO: Register(User)
        Register(vaultName: user.userName, deviceName: user.deviceName, publicKey: user.publicKey.base64EncodedString(), rsaPublicKey: user.publicRSAKey.base64EncodedString(), signature: (user.signature ?? Data()).base64EncodedString()).execute() { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == .Registered {
                    self?.deviceStatus = .member
                    self?.mainUser = user
                    self?.routeTo(.main, presentAs: .root)
                } else {
                    self?.deviceStatus = .pending
                    self?.showCommonAlert(AlertModel(title: Constants.Alert.emptyTitle, message: Constants.LoginScreen.alreadyExisted))
                }
                self?.hideLoader()
            case .failure(let error):
                self?.hideLoader()
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
    func showAwaitingAlert() {
        showCommonAlert(AlertModel(title: Constants.Errors.warning, message: Constants.LoginScreen.renameYourAccount, okButton: Constants.LoginScreen.renameOk, okHandler: { [weak self] in
            self?.resetAll()
            self?.delegate?.resetTextField()
        }, cancelHandler: {
            return
        }))
    }
    
    func checkStatus() {
        if deviceStatus == .pending {
            guard let user = mainUser else { return }
            
            GetVault(vaultName: user.userName, deviceName: user.deviceName, publicKey: user.publicKey.base64EncodedString(), rsaPublicKey: user.publicRSAKey.base64EncodedString(), signature: (user.signature ?? Data()).base64EncodedString()).execute() { [weak self] result in
                switch result {
                case .success(let result):
                    if result.status == .member {
                        self?.routeTo(.main, presentAs: .root)
                    } else if result.status == .declined {
                        self?.resetAll()
                        self?.showCommonAlert(AlertModel(title: Constants.Errors.error, message: Constants.LoginScreen.declined))
                    }
                case .failure(let error):
                    self?.showCommonError(error.localizedDescription)
                }
            }
        }
    }
}
