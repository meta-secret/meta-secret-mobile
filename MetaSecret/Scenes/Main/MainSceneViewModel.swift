//
//  MainSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation

protocol MainSceneProtocol {
    
}

final class MainSceneViewModel: Alertable, Routerable, UD {
    private var delegate: MainSceneProtocol? = nil
    private var timer: Timer? = nil
    
    //MARK: - INIT
    init(delegate: MainSceneProtocol) {
        self.delegate = delegate
        createTimer()
    }
}

private extension MainSceneViewModel {
    //MARK: - GETTING VAULT
    func getVault() {
        guard let user = readCustom(object: User.self, key: UDKeys.localVault) else {
            showCommonError(nil)
            return
        }
        
        GetVault(vaultName: user.userName, deviceName: user.deviceName, publicKey: user.publicKey.base64EncodedString(), rsaPublicKey: user.publicRSAKey.base64EncodedString(), signature: (user.signature ?? Data()).base64EncodedString()).execute() { [weak self] result in
            switch result {
            case .success(let vault):
                if !vault.isEmpty {
                    self?.showCommonAlert(AlertModel(title: Constants.Alert.emptyTitle, message: Constants.MainScreen.joinPendings, okButton: Constants.MainScreen.ok, cancelButton: Constants.MainScreen.cancel, okHandler: { [weak self] in
                        self?.accept()
                    }, cancelHandler: { [weak self] in
                        self?.cancel()
                    }))
                }
            case .failure(let error):
                self?.showCommonError(error.localizedDescription)
            }
        }
    }
    
    func accept() {
        
    }
    
    func cancel() {
        
    }
    
    //MARK: - TIMER
    func createTimer() {
        timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    @objc func fireTimer() {
        getVault()
    }
}
