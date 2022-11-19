//
//  DeviceInfoSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 30.08.2022.
//

import Foundation

protocol DeviceInfoProtocol {
    func successFullConnection()
}

final class DeviceInfoSceneViewModel: Alertable, UD, Routerable {
    
    private var delegate: DeviceInfoProtocol? = nil
    
    
    //MARK: - INIT
    init(delegate: DeviceInfoProtocol) {
        self.delegate = delegate
    }
    
    //MARK: - PUBLIC METHODS
    func acceptUser(candidate: Vault) {
        Accept(candidate: candidate).execute { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == Constants.Common.finishedStatus {
                    self?.delegate?.successFullConnection()
                } else {
                    self?.showCommonError(nil)
                }
            case .failure(let error):
                self?.showCommonError(error.localizedDescription)
            }
        }
    }
    
    func declineUser(candidate: Vault) {
        Decline(candidate: candidate).execute { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == Constants.Common.finishedStatus {
                    self?.delegate?.successFullConnection()
                } else {
                    self?.showCommonError(nil)
                }
            case .failure(let error):
                self?.showCommonError(error.localizedDescription)
            }
        }
    }
}
