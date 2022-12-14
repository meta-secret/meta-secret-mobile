//
//  DistributionConnectorManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.12.2022.
//

import Foundation

protocol DistributionConnectorManagerProtocol {
    func startMonitoringShares()
    func stopMonitoringShares()
    func startMonitoringDevices()
    func stopMonitoringDevices()
    func startMonitoringClaims(description: String)
    func stopMonitoringClaims()
    func distributeSharesToMembers(_ shares: [AeadCipherText], receiver: UserSignature, description: String, callBack: ((Bool)->())?)
}

final class DistributionConnectorManager: DistributionConnectorManagerProtocol, UD, Alertable, JsonSerealizable {
    //MARK: - PROPERTIES
    private var findSharesTimer: Timer? = nil
    private var findVaultsTimer: Timer? = nil
    private var findClaimsTimer: Timer? = nil
    private var isLookinForClaims: Bool = true
    private var isLookinForClaimRequests: Bool = true
    private var isLookinForShares: Bool = true
    private var isLookinForVaults: Bool = true
    
    private(set) var callBack: ((CallBackType)->())?
    
    enum Config {
        static let timerInterval: CGFloat = 10
    }
    
    //MARK: - INIT
    init(callBack: ((CallBackType)->())?) {
        self.callBack = callBack
    }
    
    //MARK: - MAIN SCREEN. SHARES
    func startMonitoringShares() {
        isLookinForShares = false
        isLookinForClaimRequests = false
        stopMonitoringDevices()
        if findSharesTimer == nil {
            findSharesTimer = Timer.scheduledTimer(timeInterval: Config.timerInterval, target: self, selector: #selector(fireSharesTimer), userInfo: nil, repeats: true)
        }
    }
    
    func stopMonitoringShares() {
        findSharesTimer?.invalidate()
        findSharesTimer = nil
    }
    
    //MARK: - MAIN SCREEN. VAULTS
    func startMonitoringDevices() {
        isLookinForVaults = false
        stopMonitoringShares()
        if findVaultsTimer == nil {
            findVaultsTimer = Timer.scheduledTimer(timeInterval: Config.timerInterval, target: self, selector: #selector(fireDevicesTimer), userInfo: nil, repeats: true)
        }
    }
    
    func stopMonitoringDevices() {
        findVaultsTimer?.invalidate()
        findVaultsTimer = nil
    }
    
    //MARK: - ADD SECRET SCREEN. CLAIMS
    
    func startMonitoringClaims(description: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.askingForClaims(description: description, callBack: { [weak self] isOk in
                guard let self else { return }
                if isOk {
                    self.isLookinForClaims = false
                    if self.findClaimsTimer == nil {
                        self.findClaimsTimer = Timer.scheduledTimer(timeInterval: Config.timerInterval, target: self, selector: #selector(self.fireClaimsTimer), userInfo: nil, repeats: true)
                    }
                } else {
                    self.callBack?(.Failure)
                }
            })
        }
    }
    
    func stopMonitoringClaims() {
        findClaimsTimer?.invalidate()
        findClaimsTimer = nil
    }
    
    //MARK: - ADD SECRET SCREEN SPLIT
    func distributeSharesToMembers(_ shares: [AeadCipherText], receiver: UserSignature, description: String, callBack: ((Bool)->())?) {
        for share in shares {
            distribution(encodedShare: share, receiver: receiver, description: description, type: .split, callBack: callBack)
        }
    }
}

private extension DistributionConnectorManager {
    @objc func fireSharesTimer() {
        if !isLookinForClaimRequests {
            findClaims()
        }
        if !isLookinForShares {
            findShares()
        }
    }
    
    //MARK: - SHARES ACTIONS
    func findShares() {
        isLookinForShares = true
        DispatchQueue.global(qos: .background).async { [weak self] in
            FindShares().execute { [weak self] result in
                switch result {
                case .success(let result):
                    guard result.msgType == Constants.Common.ok, !(result.data?.isEmpty ?? true) else {
                        self?.isLookinForShares = false
                        print(result.error ?? "")
                        return
                    }
                    
                    ShareDistributionManager().distribtuteToDB(result.data) { isToReload in
                        if isToReload {
                            self?.isLookinForShares = false
                            DispatchQueue.main.async {
                                self?.callBack?(.Shares)
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showCommonError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    //MARK: - CLAIMS ACTIONS
    @objc func fireClaimsTimer() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.findSharesClaim()
        }
    }
    
    func findSharesClaim() {
        FindShares().execute { [weak self] result in
            switch result {
            case .success(let result):
                guard result.msgType == Constants.Common.ok, !(result.data?.isEmpty ?? true) else {
                    DispatchQueue.main.async { [weak self] in
                        self?.showCommonError(MetaSecretErrorType.cantRestore.message())
                        self?.callBack?(.Failure)
                    }
                    return
                }
                
                guard let share = result.data?.first, share.distributionType == .recover, let keyManager = self?.securityBox?.keyManager else {
                    DispatchQueue.main.async { [weak self] in
                        self?.showCommonError(MetaSecretErrorType.cantRestore.message())
                        self?.callBack?(.Failure)
                    }
                    return
                }
                
                guard let description = share.metaPassword?.metaPassword.id.name,
                      let secret = DBManager.shared.readSecretBy(description: description) else {
                    DispatchQueue.main.async { [weak self] in
                        self?.showCommonError(MetaSecretErrorType.cantRestore.message())
                        self?.callBack?(.Failure)
                    }
                    return
                }
                
                let secretShareString = secret.shares[0]
                
                guard let docOne: SecretDistributionDoc = self?.objectGeneration(from: secretShareString) else {
                    DispatchQueue.main.async { [weak self] in
                        self?.showCommonError(MetaSecretErrorType.cantRestore.message())
                        self?.callBack?(.Failure)
                    }
                    return
                }
                
                self?.stopMonitoringClaims()
                let model = RestoreModel(keyManager: keyManager, docOne: docOne, docTwo: share)
                let decriptedSecret = RustTransporterManager().restoreSecret(model: model)
                DispatchQueue.main.async { [weak self] in
                    self?.callBack?(.Claims(decriptedSecret))
                }
                
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.showCommonError(MetaSecretErrorType.cantRestore.message())
                    self?.callBack?(.Failure)
                }
            }
        }
    }
    
    func askingForClaims(description: String, callBack: ((Bool)->())?) {
        guard let userSignature, let secret = DBManager.shared.readSecretBy(description: description) else {
            DispatchQueue.main.async { [weak self] in
                callBack?(false)
                self?.showCommonError(MetaSecretErrorType.cantRestore.message())
            }
            return
        }

        let sharesArray = Array(secret.shares)
        guard let shareString = sharesArray.first else {
            DispatchQueue.main.async { [weak self] in
                callBack?(false)
                self?.showCommonError(MetaSecretErrorType.cantRestore.message())
            }
            return
        }
        let shareObject: SecretDistributionDoc? = objectGeneration(from: shareString)
        
        let myGroup = DispatchGroup()
        var results = [Bool]()
        
        guard let members = shareObject?.metaPassword?.metaPassword.vault.signatures else {
            DispatchQueue.main.async { [weak self] in
                callBack?(false)
                self?.showCommonError(MetaSecretErrorType.cantRestore.message())
            }
            return
        }
        
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
                    DispatchQueue.main.async { [weak self] in
                        self?.showCommonError(error.localizedDescription)
                    }
                    break
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            guard let _ = results.first(where: {$0 == false}) else {
                callBack?(true)
                return
            }
            callBack?(false)
        }
    }
    
    func findClaims() {
        isLookinForClaimRequests = true
        DispatchQueue.global(qos: .background).async { [weak self] in
            FindClaims().execute { [weak self] result in
                switch result {
                case .success(let result):
                    guard result.msgType == Constants.Common.ok, !(result.data?.isEmpty ?? true) else {
                        self?.isLookinForClaimRequests = false
                        print("== NO CLAIMS FOR \(self?.userSignature?.device.deviceName ?? "") ==")
                        return
                    }
                    self?.distributeClaimsToRestore(claims: result.data)
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.isLookinForClaimRequests = false
                        self?.showCommonError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func distributeClaimsToRestore(claims: [PasswordRecoveryRequest]?) {
        guard let claims else {
            DispatchQueue.main.async { [weak self] in
                self?.showCommonError(MetaSecretErrorType.cantClaim.message())
            }
            isLookinForClaimRequests = false
            return
        }
        
        for claim in claims {
            guard let description = claim.id.name, let secret = DBManager.shared.readSecretBy(description: description) else {
                DispatchQueue.main.async { [weak self] in
                    self?.showCommonError(MetaSecretErrorType.cantClaim.message())
                }
                isLookinForClaimRequests = false
                return
            }
            
            guard let shareString = secret.shares.first else {
                DispatchQueue.main.async { [weak self] in
                    self?.showCommonError(MetaSecretErrorType.cantClaim.message())
                }
                isLookinForClaimRequests = false
                return
            }
            
            guard let secretDoc: SecretDistributionDoc = objectGeneration(from: shareString),
                  let encryptedShare = secretDoc.secretMessage?.encryptedText else {
                DispatchQueue.main.async { [weak self] in
                    self?.showCommonError(MetaSecretErrorType.cantClaim.message())
                }
                isLookinForClaimRequests = false
                return
            }
            
            distribution(encodedShare: encryptedShare, receiver: claim.consumer, description: description, type: .recover, callBack: { [weak self] _ in
                self?.isLookinForClaimRequests = false
            })
        }
    }
    
    //MARK: - VAULTS ACTIONS
    @objc func fireDevicesTimer() {
        if !isLookinForVaults {
            getVault()
        }
    }
    
    func getVault() {
        isLookinForVaults = true
        DispatchQueue.global(qos: .background).async { [weak self] in
            GetVault().execute() { [weak self] result in
                switch result {
                case .success(let result):
                    guard result.msgType == Constants.Common.ok else {
                        DispatchQueue.main.async {
                            self?.showCommonError(result.error ?? "")
                        }
                        return
                    }
                    
                    self?.mainVault = result.data?.vault
                    DispatchQueue.main.async {
                        self?.callBack?(.Devices)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showCommonError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    //MARK: - DISTRIBUTE ACTIONS
    func distribution(encodedShare: AeadCipherText, receiver: UserSignature, description: String, type: SecretDistributionType, callBack: ((Bool)->())?) {
        Distribute(encodedShare: encodedShare, receiver: receiver, description: description, type: type).execute() { [weak self] result in
            switch result {
            case .failure(let err):
                DispatchQueue.main.async {
                    self?.showCommonError(err.localizedDescription)
                }
                callBack?(false)
            case .success(let result):
                if result.msgType != Constants.Common.ok {
                    DispatchQueue.main.async {
                        self?.showCommonError(result.error)
                    }
                }
                callBack?(true)
            }
        }
    }
}

enum CallBackType {
    case Shares
    case Devices
    case Claims(String?)
    case Failure
}

