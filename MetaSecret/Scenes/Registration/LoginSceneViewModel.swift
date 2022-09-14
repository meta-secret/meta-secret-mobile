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
    func processFinished()
    func showPendingPopup()
}

final class LoginSceneViewModel: Signable, Alertable, Routerable {
    private var delegate: LoginSceneProtocol? = nil
    
    //MARK: - INIT
    init(delegate: LoginSceneProtocol) {
        self.delegate = delegate
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.checkStatus()
        }
    }
    
    //MARK: - REGISTRATION
    func register(_ userName: String) {
        if deviceStatus == .pending {
            DispatchQueue.main.async { [weak self] in
                self?.showAwaitingAlert()
                self?.delegate?.processFinished()
            }
            return
        }
        
        guard let user = generateKeys(for: userName) else {
            DispatchQueue.main.async { [weak self] in
                self?.showCommonError(nil)
                self?.delegate?.processFinished()
            }

            return
        }
        
        let userNameData = user.userName.data(using: .utf8) ?? Data()
        signData(userNameData, for: user)
        
        mainUser = user
        
        Register().execute() { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == .Registered {
                    self?.deviceStatus = .member
                    self?.mainUser = user
                    self?.isOwner = true //TODO: Need it on Server
                    DispatchQueue.main.async {
                        self?.routeTo(.main, presentAs: .root)
                    }
                } else {
                    self?.deviceStatus = .pending
                    DispatchQueue.main.async {
                        self?.showCommonAlert(AlertModel(title: Constants.Alert.emptyTitle, message: Constants.LoginScreen.alreadyExisted, okHandler: { [weak self] in
                            self?.delegate?.showPendingPopup()
                        }, cancelHandler: { [weak self] in
                            self?.mainUser = nil
                            self?.deviceStatus = .unknown
                        }))
                    }
                }
                DispatchQueue.main.async {
                    self?.delegate?.processFinished()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.delegate?.processFinished()
                    self?.showCommonError(error.localizedDescription)
                }
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
        }, cancelHandler: { [weak self] in
            self?.deviceStatus = .unknown
            return
        }))
    }
    
    func checkStatus() {
        if deviceStatus == .pending {
            GetVault().execute() { [weak self] result in
                switch result {
                case .success(let result):
                    if result.status == .member {
                        DispatchQueue.main.async {
                            self?.routeTo(.main, presentAs: .root)
                        }
                    } else if result.status == .declined {
                        self?.resetAll()
                        DispatchQueue.main.async {
                            self?.showCommonAlert(AlertModel(title: Constants.Errors.error, message: Constants.LoginScreen.declined))
                        }
                    } else {
                        self?.delegate?.showPendingPopup()
                    }
                    self?.delegate?.processFinished()
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.delegate?.processFinished()
                        self?.showCommonError(error.localizedDescription)
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.delegate?.processFinished()
        }
    }
}
