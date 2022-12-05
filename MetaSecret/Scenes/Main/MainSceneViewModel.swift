//
//  MainSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation
import RealmSwift

protocol MainSceneProtocol {
    func reloadData(source: MainScreenSource?)
}

final class MainSceneViewModel: Alertable, Routerable, UD, Signable {
    //MARK: - PROPERTIES
    private var delegate: MainSceneProtocol? = nil
    private var timer: Timer? = nil
    private var pendings: [VaultDoc]? = nil
    private var source: MainScreenSource? = nil
    private var type: MainScreenSourceType = .Secrets
    
    enum Config {
        static let timerInterval: CGFloat = 10
    }
    
    //MARK: - INIT
    init(delegate: MainSceneProtocol) {
        self.delegate = delegate
        createTimer()
    }
    
    //MARK: - PUBLIC METHODS
    func getAllSecrets() {
        showLoader()
        DispatchQueue.main.async { [weak self] in
            self?.source = SecretsDataSource().getDataSource(for: DBManager.shared.getAllSecrets())
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
                    guard result.msgType == Constants.Common.ok else {
                        print(result.error ?? "")
                        return
                    }
                    
                    self?.mainVault = result.data?.vault
                    guard let vault = self?.mainVault else { return }
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
        self.type = type
        switch type {
        case .Secrets:
            getAllSecrets()
        case .Devices:
            getVault()
        default:
            break
        }
    }
}

private extension MainSceneViewModel {
    //MARK: - TIMER
    func createTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: Config.timerInterval, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func fireTimer() {
        switch type {
        case .Secrets:
            findShares()
        case .Devices:
            getVault()
        case .None:
            break
        }
    }
    
    func findShares() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            FindShares().execute { [weak self] result in
                switch result {
                case .success(let result):
                    guard result.msgType == Constants.Common.ok else {
                        print(result.error ?? "")
                        return
                    }
                    
                    ShareDistributionManager().distribtuteToDB(result.data) { isToReload in
                        if isToReload {
                            self?.getAllSecrets()
                        }
                    }
                case .failure(let error):
                    self?.showCommonError(error.localizedDescription)
                }
            }
        }
    }
}
