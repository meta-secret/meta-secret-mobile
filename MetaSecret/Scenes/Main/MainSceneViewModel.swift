//
//  MainSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation

protocol MainSceneProtocol {
    func reloadData(source: MainScreenSource)
}

final class MainSceneViewModel: Alertable, Routerable, UD {
    private var delegate: MainSceneProtocol? = nil
    private var timer: Timer? = nil
    private var pendings: [Vault]? = nil
    private var source: MainScreenSource? = nil
    var vault: Vault? = nil
    
    //MARK: - INIT
    init(delegate: MainSceneProtocol) {
        self.delegate = delegate
//        createTimer()
    }
    
    //MARK: - PUBLIC METHODS
    func getAllSecrets() {
        guard let user = mainUser else {
            showCommonError(nil)
            return
        }
        
        showLoader()
        FindShares(user: user).execute() { [weak self] result in
            switch result {
            case .success(let result):
                break
                
            case .failure(let error):
                self?.showCommonError(error.localizedDescription)
            }
        }
    }
    
    func getVault() {
        guard let user = mainUser else {
            showCommonError(nil)
            return
        }
        
        GetVault(user: user).execute() { [weak self] result in
            switch result {
            case .success(let result):
                self?.vault = result.vault
                guard let vault = self?.vault else { return }
                self?.source = DevicesDataSource().getDataSource(for: vault)
                
                guard let source = self?.source else { return }
                self?.delegate?.reloadData(source: source)
            case .failure(let error):
                self?.showCommonError(error.localizedDescription)
            }
        }
    }
    
    func getNewDataSource(type: MainScreenSourceType) {
        switch type {
        case .Vaults:
            getAllSecrets()
        case .Devices:
            getVault()
        default:
            break
        }
    }
    
}

private extension MainSceneViewModel {
    func accept() {
        stopTimer()
    }
    
    func cancel() {
        stopTimer()
    }
    
    //MARK: - TIMER
    func createTimer() {
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func fireTimer() {
        getVault()
    }
}
