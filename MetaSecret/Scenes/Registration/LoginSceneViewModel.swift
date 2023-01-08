//
//  LoginSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit
import CryptoKit
import PromiseKit

protocol LoginSceneProtocol {
    func showPendingPopup()
    func showAwaitingAlert()
    func routeNext()
    func alreadyExisted()
    func failed(with error: Error)
    func closePopUp()
}

final class LoginSceneViewModel: CommonViewModel {
    private var tempTimer: Timer? = nil
    private var userService: UsersServiceProtocol
    private var signingManager: Signable
    private var jsonManager: JsonSerealizable
    private var authService: AuthorizationProtocol
    private var vaultService: VaultAPIProtocol
    
    var delegate: LoginSceneProtocol? = nil
    
    //MARK: - INIT
    init(userService: UsersServiceProtocol, signingManager: Signable, jsonManager: JsonSerealizable, authService: AuthorizationProtocol, vaultService: VaultAPIProtocol) {
        self.signingManager = signingManager
        self.userService = userService
        self.jsonManager = jsonManager
        self.authService = authService
        self.vaultService = vaultService
    }
    
    override func loadData() -> Promise<Void> {
        isLoadingData = true
        return firstly {
            checkStatus()
        }.ensure {
            self.isLoadingData = false
        }.asVoid()
    }
    
    //MARK: - PUBLIC METHODS
    func startTimer() {
        guard self.tempTimer == nil else { return }
        delegate?.showPendingPopup()
        tempTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: true)
    }
    
    //MARK: - REGISTRATION
    func register(_ userName: String) -> Promise<Void> {
        isLoadingData = true
        if userService.deviceStatus == .pending {
            delegate?.showAwaitingAlert()
            isLoadingData = false
            return Promise().asVoid()
        }
        
        guard let userSecurityBox = signingManager.generateKeys(for: userName) else {
            return Promise(error: MetaSecretErrorType.generateUser)
        }
        
        let user = UserSignature(vaultName: userName,
                                 signature: userSecurityBox.signature,
                                 publicKey: userSecurityBox.keyManager.dsa.publicKey,
                                 transportPublicKey: userSecurityBox.keyManager.transport.publicKey,
                                 device: Device())

        return firstly {
            authService.register(user)
        }.get { result in
            if result.data == .Registered {
                self.userService.deviceStatus = .member
                self.userService.securityBox = userSecurityBox
                self.userService.userSignature = user
                self.userService.isOwner = true
                self.delegate?.routeNext()
            } else {
                self.userService.deviceStatus = .pending
                self.userService.userSignature = user
                self.userService.securityBox = userSecurityBox
                self.delegate?.alreadyExisted()
            }
        }.ensure {
            self.isLoadingData = false
        }.asVoid()
    }
}

private extension LoginSceneViewModel {
    func checkStatus() -> Promise<Void> {
        if userService.deviceStatus == .pending {
            return firstly {
                vaultService.getVault()
            }.get { result in
                if result.data?.vaultInfo == .member {
                    self.userService.deviceStatus = .member
                    self.tempTimer?.invalidate()
                    self.tempTimer = nil
                    self.delegate?.closePopUp()
                    self.delegate?.routeNext()
                } else if result.data?.vaultInfo == .declined {
                    self.delegate?.closePopUp()
                    self.userService.resetAll()
                    self.delegate?.failed(with: MetaSecretErrorType.declinedUser)
                } else {
                    self.startTimer()
                }
            }.ensure {
                self.isLoadingData = false
            }.asVoid()
        } else {
            return Promise().asVoid()
        }
    }
    
    @objc func fireTimer() {
        checkStatus()
    }
}
