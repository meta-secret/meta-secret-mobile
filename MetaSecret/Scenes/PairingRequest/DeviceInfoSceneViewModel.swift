//
//  DeviceInfoSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 30.08.2022.
//

import Foundation

protocol DeviceInfoProtocol {
    func successFullConnection(isAccept: Bool)
}

final class DeviceInfoSceneViewModel: CommonViewModel {
    var delegate: DeviceInfoProtocol? = nil
    private var alertService: Alertable
    
    //MARK: - INIT
    init(alertService: Alertable) {
        #warning("Should not be there")
        self.alertService = alertService
    }
    
    //MARK: - PUBLIC METHODS
    func acceptUser(candidate: UserSignature) {
        Accept(candidate: candidate).execute { [weak self] result in
            switch result {
            case .success(let response):
                if response.msgType == Constants.Common.ok {
                    self?.delegate?.successFullConnection(isAccept: true)
                } else {
                    self?.alertService.showCommonError(nil)
                }
            case .failure(let error):
                self?.alertService.showCommonError(error.localizedDescription)
            }
        }
    }
    
    func declineUser(candidate: UserSignature) {
        Decline(candidate: candidate).execute { [weak self] result in
            switch result {
            case .success(let response):
                if response.msgType == Constants.Common.ok {
                    self?.delegate?.successFullConnection(isAccept: false)
                } else {
                    self?.alertService.showCommonError(nil)
                }
            case .failure(let error):
                self?.alertService.showCommonError(error.localizedDescription)
            }
        }
    }
}
