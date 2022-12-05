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

final class LoginSceneViewModel: Signable, UD, RootFindable, Alertable, Routerable {
    private var delegate: LoginSceneProtocol? = nil
    private var tempTimer: Timer? = nil
    
    //MARK: - INIT
    init(delegate: LoginSceneProtocol) {
        self.delegate = delegate
//        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Common.waitingTime, execute: { [weak self] in
            checkStatus()
//        })
    }
    
    //MARK: - REGISTRATION
    func register(_ userName: String) {
        if deviceStatus == .pending {
            showAwaitingAlert()
            delegate?.processFinished()
            return
        }
        
        guard let userSecurityBox = generateKeys(for: userName) else {
            showCommonError(MetaSecretErrorType.generateUser.message())
            delegate?.processFinished()
            return
        }
        
        let user = UserSignature(vaultName: userName,
                                 signature: userSecurityBox.signature,
                                 publicKey: userSecurityBox.keyManager.dsa.publicKey,
                                 transportPublicKey: userSecurityBox.keyManager.transport.publicKey,
                                 device: Device())

        Register(user).execute() { [weak self] result in
            switch result {
            case .success(let response):
                guard response.msgType == Constants.Common.ok else {
                    print(response.error ?? "")
                    return
                }
                
                if response.data == .Registered {
                    self?.deviceStatus = .member
                    self?.securityBox = userSecurityBox
                    self?.userSignature = user
                    self?.isOwner = true
                    self?.routeTo(.main, presentAs: .root)
                } else {
                    self?.deviceStatus = .pending
                    self?.userSignature = user
                    self?.securityBox = userSecurityBox
                    self?.showCommonAlert(AlertModel(title: Constants.Alert.emptyTitle, message: Constants.LoginScreen.alreadyExisted, okHandler: { [weak self] in
                        guard let `self` = self else { return }
                        
                        if self.tempTimer == nil {
                            self.delegate?.showPendingPopup()
                            self.tempTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: true)
                        }
                    }, cancelHandler: { [weak self] in
                        self?.userSignature = nil
                        self?.deviceStatus = .unknown
                    }))
                }
                self?.delegate?.processFinished()
            case .failure(let error):
                self?.delegate?.processFinished()
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
        showCommonAlert(AlertModel(title: Constants.Errors.warning, message: Constants.LoginScreen.chooseAnotherName, okButton: Constants.LoginScreen.renameOk, okHandler: { [weak self] in
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
                    guard result.msgType == Constants.Common.ok else {
                        print(result.error ?? "")
                        return
                    }
                    if result.data?.vaultInfo == .member {
                        self?.closePopup()
                        self?.routeTo(.main, presentAs: .root)
                    } else if result.data?.vaultInfo == .declined {
                        self?.closePopup()
                        self?.resetAll()

                        self?.showCommonAlert(AlertModel(title: Constants.Errors.error, message: Constants.LoginScreen.declined))
                    } else {
                        guard let `self` = self else { return }
                        
                        if self.tempTimer == nil {
                            self.delegate?.showPendingPopup()
                            self.tempTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: true)
                        }
                    }
                    self?.delegate?.processFinished()
                case .failure(let error):
                    self?.delegate?.processFinished()
                    self?.showCommonError(error.localizedDescription)
                }
            }
        }

        self.delegate?.processFinished()
    }
    
    @objc func fireTimer() {
        checkStatus()
    }
    
    func closePopup() {
        tempTimer?.invalidate()
        tempTimer = nil
        
        guard let vc = findTop(), let popupVC = vc as? PopupHintViewScene else {
            return
        }
        popupVC.closeHint()
    }
}
