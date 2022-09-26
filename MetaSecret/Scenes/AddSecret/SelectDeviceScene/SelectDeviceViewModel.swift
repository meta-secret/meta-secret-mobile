//
//  SelectDeviceViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 07.09.2022.
//

import Foundation

protocol SelectDeviceProtocol {
    func reloadData(source: [Vault])
}

final class SelectDeviceViewModel: Alertable, Signable {
    //MARK: - PROPERTIES
    
    private var delegate: SelectDeviceProtocol? = nil
    
    //MARK: - INIT
    init(delegate: SelectDeviceProtocol) {
        self.delegate = delegate
        fetchAllDevices()
    }
    
    //MARK: - PUBLIC METHODS
    func send(_ share: String, to member: Vault, with note: String, callback: (()->())?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Common.waitingTime, execute: { [weak self] in
            guard let key = member.rsaPublicKey?.data(using: .utf8), let name = member.vaultName else {
                self?.showCommonError(nil)
                return
            }
            
            let encryptedPartOfCode = self?.encryptData(Data(share.utf8), key: key, name: name)
            
            let secret = Secret()
            secret.secretID = note
            secret.secretPart = encryptedPartOfCode

            Distribute(encryptedShare: encryptedPartOfCode?.base64EncodedString() ?? "").execute() { [weak self] result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    self?.showCommonError(error.localizedDescription)
                }
                self?.hideLoader()
            }
        })
    }
}

private extension SelectDeviceViewModel {
    func fetchAllDevices() {
        GetVault().execute() { [weak self] result in
            switch result {
            case .success(let vaults):
                guard let members = vaults.vault?.signatures else { return }
                self?.delegate?.reloadData(source: members)
            case .failure(let error):
                self?.showCommonError(error.localizedDescription)
            }
            
        }
    }
    
    func shareSentAlert(deviceName: String) {
//        let model = AlertModel(title: <#T##String#>, message: <#T##String#>)
    }
}
