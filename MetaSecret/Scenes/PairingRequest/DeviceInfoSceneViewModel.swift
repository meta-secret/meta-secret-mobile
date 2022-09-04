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
        guard let member = mainUser else {
            showCommonError(nil)
            return }
        Accept(member: member, candidate: candidate).execute { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == "Successful" {
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
        guard let member = mainUser else {
            showCommonError(nil)
            return }
        Decline(member: member, candidate: candidate).execute { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == "Successful" {
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
