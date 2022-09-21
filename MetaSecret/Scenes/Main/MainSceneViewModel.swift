//
//  MainSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation

protocol MainSceneProtocol {
    func reloadData(source: MainScreenSource?)
}

final class MainSceneViewModel: Alertable, Routerable, UD, Signable {
    //MARK: - PROPERTIES
    private var delegate: MainSceneProtocol? = nil
    private var timer: Timer? = nil
    private var pendings: [Vault]? = nil
    private var source: MainScreenSource? = nil
    var vault: Vault? = nil
    
    //MARK: - INIT
    init(delegate: MainSceneProtocol) {
        self.delegate = delegate
    }
    
    //MARK: - PUBLIC METHODS
    func getAllSecrets() {
        showLoader()
        DispatchQueue.main.async { [weak self] in
            self?.source = VaultsDataSource().getDataSource(for: DBManager.shared.getAllSecrets())
            guard let `self` = self else { return }
            self.delegate?.reloadData(source: self.source)
        }
    }
    
    func getVault() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            GetVault().execute() { [weak self] result in
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
    }
    
    func getNewDataSource(type: MainScreenSourceType) {
        switch type {
        case .Secrets:
            getAllSecrets()
        case .Devices:
            getVault()
        default:
            break
        }
    }
    
    func generateVirtualVaults() {
        showLoader()
        DispatchQueue.main.async { [weak self] in
            guard let mainUser = self?.mainUser else {
                self?.showCommonError(nil)
                return
            }
            
            var virtualUsers = [User]()
            
            for i in 0..<2 {
                if let vUser = self?.generateKeys(for: "\(mainUser.userName)_\(Constants.Common.virtual)\(i+1)") {
                    virtualUsers.append(vUser)
                }
            }
            
            self?.vUsers = virtualUsers
            self?.hideLoader()
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
