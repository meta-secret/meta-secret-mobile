//
//  DeviceInfoSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 30.08.2022.
//

import Foundation
import PromiseKit

protocol DeviceInfoProtocol {}

final class DeviceInfoSceneViewModel: CommonViewModel {
    override var title: String {
        return Constants.PairingDeveice.title
    }

    private var vaultApiService: VaultAPIProtocol
    
    //MARK: - INIT
    init(vaultApiService: VaultAPIProtocol) {
        self.vaultApiService = vaultApiService
    }
    
    //MARK: - PUBLIC METHODS
    func acceptUser(candidate: UserSignature) -> Promise<Void> {
        return firstly{
            vaultApiService.accept(candidate)
        }.then { result in
            self.checkResult(result: result)
        }.asVoid()
    }
    
    func declineUser(candidate: UserSignature) -> Promise<Void> {
        return firstly{
            vaultApiService.decline(candidate)
        }.then { result in
            self.checkResult(result: result)
        }.asVoid()
    }
    
    private func checkResult(result: AcceptResult) -> Promise<Void> {
        guard result.msgType == Constants.Common.ok else { return Promise(error: MetaSecretErrorType.networkError) }
        return Promise().asVoid()
    }
}
