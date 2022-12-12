//
//  AddSecretViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation
import UIKit

protocol AddSecretProtocol {
    func close()
    func showRestoreResult(password: String?)
}

final class AddSecretViewModel: UD, Routerable, Signable, JsonSerealizable {
    //MARK: - PROPERTIES
    enum Config {
        static let minMembersCount = 3
        static let timerInterval: CGFloat = 10
    }
    
    private var delegate: AddSecretProtocol? = nil
    private var components: [UserShareDto] = [UserShareDto]()
    private var signatures: [UserSignature]? = nil
    private lazy var activeSignatures: [UserSignature] = [UserSignature]()
    private var description: String = ""
    private var distributionManager: ShareDistributionable? = nil
    private var timer: Timer? = nil
    
    var isFullySplitted: Bool = false
    
    //MARK: - INIT
    init(delegate: AddSecretProtocol) {
        self.delegate = delegate
        distributionManager = ShareDistributionManager()
    }
    
    //MARK: - PUBLIC METHODS
    func getVault(completion: (()->())?) {
        GetVault().execute() { [weak self] result in
            switch result {
            case .success(let result):
                guard result.msgType == Constants.Common.ok else {
                    print(result.error ?? "")
                    return
                }
                
                self?.signatures?.removeAll()
                self?.signatures = result.data?.vault?.signatures
                if self?.signatures?.count ?? 0 <= Constants.Common.neededMembersCount {
                    self?.activeSignatures = self?.signatures ?? []
                }
                completion?()
            case .failure(let error):
                completion?()
                self?.hideLoader()
                self?.showCommonError(error.localizedDescription)
            }
        }
    }
    
    func vaultsCount() -> Int {
        return signatures?.count ?? 0
    }
    
    func split(secret: String, description: String, callBack: ((Bool)->())?) {
        self.description = description
        
        if let _ = readMySecret(description: "\(self.description)") {
            let model = AlertModel(title: Constants.Errors.warning, message: Constants.AddSecret.alreadySavedMessage, okHandler:  { [weak self] in
                self?.splitInternal(secret, callBack: callBack)
            })
            showCommonAlert(model)
        } else {
            splitInternal(secret, callBack: callBack)
        }
    }
    
    func encryptAndDistribute(callBack: ((Bool)->())?) {
        distributionManager?.distributeShares(components, activeSignatures, description: description, callBack: callBack)
    }
    
    func showDeviceLists(callBack: ((Bool)->())?) {
        let model = SceneSendDataModel(signatures: signatures, callBackSignatures: { [weak self] signatures in
            self?.activeSignatures = signatures
            self?.encryptAndDistribute(callBack: { isSuccess in
                callBack?(isSuccess)
            })
        })
        routeTo(.selectDevice, presentAs: .push, with: model)
    }
    
    func requestClaims(_ description: String, callBack: ((Bool)->())?) {
        guard let userSignature, let secret = DBManager.shared.readSecretBy(description: description) else {
            showCommonError(MetaSecretErrorType.cantRestore.message())
            return }

        let sharesArray = Array(secret.shares)
        guard let shareString = sharesArray.first else {
            showCommonError(MetaSecretErrorType.cantRestore.message())
            return }
        let shareObject: SecretDistributionDoc? = objectGeneration(from: shareString)
        
        let myGroup = DispatchGroup()
        var results = [Bool]()
        
        guard let members = shareObject?.metaPassword?.metaPassword.vault.signatures else {
            showCommonError(MetaSecretErrorType.cantRestore.message())
            return }
        #warning("signature make equitable")
        let otherDevices = members.filter({ $0.signature.base64Text != userSignature.signature.base64Text})
        let otherMembers = otherDevices.isEmpty ? [userSignature] : otherDevices
        
        for member in otherMembers {
            myGroup.enter()
            print("## ASK CLAIM FROM \(userSignature.device.deviceName) TO \(member.device.deviceName)")
            Claim(provider: member, secret: secret).execute() { [weak self] result in
                switch result {
                case .success(let result):
                    guard result.msgType == Constants.Common.ok else {
                        print(result.error ?? "")
                        results.append(false)
                        myGroup.leave()
                        break
                    }
                    results.append(true)
                    myGroup.leave()
                case .failure(let error):
                    callBack?(false)
                    results.append(false)
                    myGroup.leave()
                    print(error.localizedDescription)
                    self?.showCommonError(error.localizedDescription)
                    break
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            guard let _ = results.first(where: {$0 == false}) else {
                self.startWaitingShares()
                callBack?(true)
                return
            }
            callBack?(false)
        }
    }

    func startWaitingShares() {
        createTimer()
    }
}

private extension AddSecretViewModel {
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
        findShares()
    }
    
    func findShares() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            FindShares().execute { [weak self] result in
                switch result {
                case .success(let result):
                    guard result.msgType == Constants.Common.ok, !(result.data?.isEmpty ?? true) else {
                        self?.showCommonError(MetaSecretErrorType.cantRestore.message())
                        self?.delegate?.showRestoreResult(password: nil)
                        return
                    }
                    
                    guard let share = result.data?.first, share.distributionType == .recover, let keyManager = self?.securityBox?.keyManager else {
                        self?.showCommonError(MetaSecretErrorType.cantRestore.message())
                        self?.delegate?.showRestoreResult(password: nil)
                        return
                    }
                    
                    guard let description = share.metaPassword?.metaPassword.id.name,
                          let secret = DBManager.shared.readSecretBy(description: description) else {
                        self?.showCommonError(MetaSecretErrorType.cantRestore.message())
                        self?.delegate?.showRestoreResult(password: nil)
                        return
                    }
                    
                    let secretShareString = secret.shares[0]
                    
                    guard let docOne: SecretDistributionDoc = self?.objectGeneration(from: secretShareString) else {
                        self?.showCommonError(MetaSecretErrorType.cantRestore.message())
                        self?.delegate?.showRestoreResult(password: nil)
                        return
                    }
                    
                    self?.stopTimer()
                    let model = RestoreModel(keyManager: keyManager, docOne: docOne, docTwo: share)
                    let decriptedSecret = RustTransporterManager().restoreSecret(model: model)
                    self?.delegate?.showRestoreResult(password: decriptedSecret)
                    
                case .failure(let error):
                    self?.showCommonError(error.localizedDescription)
                }
            }
        }
    }
    
    func splitInternal(_ secret: String, callBack: ((Bool)->())?) {
        components = RustTransporterManager().split(secret: secret)
        callBack?(!components.isEmpty)
    }
    
    //MARK: - WORK WITH DB    
    func readMySecret(description: String) -> Secret? {
        return DBManager.shared.readSecretBy(description: description)
    }
}
