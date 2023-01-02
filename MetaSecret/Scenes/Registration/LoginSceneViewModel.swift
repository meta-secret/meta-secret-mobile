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
    func resetTextField()
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
    
    var delegate: LoginSceneProtocol? = nil
    
    //MARK: - INIT
    init(userService: UsersServiceProtocol, signingManager: Signable, jsonManager: JsonSerealizable) {
        self.signingManager = signingManager
        self.userService = userService
        self.jsonManager = jsonManager
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
        if userService.deviceStatus == .pending {
            delegate?.showAwaitingAlert()
//            delegate?.processFinished(with: nil)
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

        Register(user).execute() { [weak self] result in
            switch result {
            case .success(let response):
                guard response.msgType == Constants.Common.ok else {
                    self?.delegate?.failed(with: MetaSecretErrorType.commonError)
                    return
                }
                
                let data = RegisterStatusResult(rawValue: response.data ?? "")
                if data == .Registered {
                    self?.userService.deviceStatus = .member
                    self?.userService.securityBox = userSecurityBox
                    self?.userService.userSignature = user
                    self?.userService.isOwner = true
                    self?.delegate?.routeNext()
                } else {
                    self?.userService.deviceStatus = .pending
                    self?.userService.userSignature = user
                    self?.userService.securityBox = userSecurityBox
                    self?.delegate?.alreadyExisted()
                }
            case .failure(let error):
                self?.delegate?.failed(with: error)
            }
        }
        return Promise().asVoid()
    }
}

private extension LoginSceneViewModel {
    func checkStatus() -> Promise<Void> {
        if userService.deviceStatus == .pending {
            GetVault().execute() { [weak self] result in
                switch result {
                case .success(let result):
                    guard result.msgType == Constants.Common.ok else {
                        print(result.error ?? "")
                        return
                    }
                    
                    let object: GetVaultData? = try? self?.jsonManager.objectGeneration(from: result.data ?? "")
                    if object?.vaultInfo == .member {
                        self?.tempTimer?.invalidate()
                        self?.tempTimer = nil
                        self?.delegate?.closePopUp()
                        self?.delegate?.routeNext()
                    } else if object?.vaultInfo == .declined {
                        self?.delegate?.closePopUp()
                        self?.userService.resetAll()
                        self?.delegate?.failed(with: MetaSecretErrorType.declinedUser)
                    } else {
                        self?.startTimer()
                    }
//                    return Promise().asVoid()
                case .failure(let error):
//                    return Promise(error: error)
                    self?.delegate?.failed(with: error)
                }
            }
        }

        return Promise().asVoid()
    }
    
    @objc func fireTimer() {
        checkStatus()
    }
}
