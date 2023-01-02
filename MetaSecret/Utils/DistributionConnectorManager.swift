//
//  DistributionConnectorManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.12.2022.
//

import Foundation

protocol DistributionConnectorManagerProtocol {
    func startMonitoringSharesAndClaimRequests()
    func stopMonitoringSharesAndClaimRequests()
    func startMonitoringVaults()
    func stopMonitoringVaults()
    func startMonitoringClaimResponses(description: String)
    func stopMonitoringClaimResponses()
    func distributeSharesToMembers(_ shares: [AeadCipherText], receiver: UserSignature, description: String, callBack: ((Bool)->())?)
    func getVault()
}

final class DistributionConnectorManager: NSObject, DistributionConnectorManagerProtocol  {
    //MARK: - PROPERTIES
    private var findSharesAndClaimRequestsTimer: Timer? = nil
    private var findVaultsTimer: Timer? = nil
    private var findClaimResponsesTimer: Timer? = nil
    
    private var isLookinForClaimResponses: Bool = true
    private var isLookinForClaimRequests: Bool = true
    private var isLookinForShares: Bool = true
    private var isLookinForVaults: Bool = true
    private var isNeedToRedistribute: Bool = false
    
    let nc = NotificationCenter.default
    
    enum Config {
        static let timerInterval: CGFloat = 10.0
    }
    
    private var userService: UsersServiceProtocol
    private let alertManager: Alertable
    private let jsonManager: JsonSerealizable
    private let dbManager: DBManager
    private let rustManager: RustProtocol
    private let sharesManager: ShareDistributionManager
    
    //MARK: - INIT
    init(userService: UsersServiceProtocol, alertManager: Alertable, jsonManager: JsonSerealizable, dbManager: DBManager, rustManager: RustProtocol, sharesManager: ShareDistributionManager) {
        self.userService = userService
        self.alertManager = alertManager
        self.jsonManager = jsonManager
        self.dbManager = dbManager
        self.rustManager = rustManager
        self.sharesManager = sharesManager
    }
    
    //MARK: - MAIN SCREEN. SHARES
    ///This method for monitoring on MianScreen Secrets tab
    func startMonitoringSharesAndClaimRequests() {
        isLookinForShares = false
        isLookinForClaimRequests = false
        stopMonitoringVaults()
        stopMonitoringClaimResponses()
        stopMonitoringClaimResponses()
        if findSharesAndClaimRequestsTimer == nil {
            print("## SHARES AND CLAIM REQUESTS TIMER STARTED")
            findSharesAndClaimRequestsTimer = Timer.scheduledTimer(timeInterval: Config.timerInterval, target: self, selector: #selector(fireSharesAndClaimRequestsTimer), userInfo: nil, repeats: true)
        }
    }
    
    func stopMonitoringSharesAndClaimRequests() {
        print("## SHARES AND CLAIM REQUESTS TIMER STOPED")
        findSharesAndClaimRequestsTimer?.invalidate()
        findSharesAndClaimRequestsTimer = nil
    }
    
    //MARK: - MAIN SCREEN. VAULTS
    func startMonitoringVaults() {
        isLookinForVaults = false
        stopMonitoringSharesAndClaimRequests()
        stopMonitoringClaimResponses()
        if findVaultsTimer == nil {
            print("## VAULTS TIMER STARTED")
            findVaultsTimer = Timer.scheduledTimer(timeInterval: Config.timerInterval, target: self, selector: #selector(fireVaultsTimer), userInfo: nil, repeats: true)
        }
    }
    
    func stopMonitoringVaults() {
        print("## VAULTS TIMER STOPED")
        findVaultsTimer?.invalidate()
        findVaultsTimer = nil
    }
    
    //MARK: - ADD SECRET SCREEN. CLAIMS
    func startMonitoringClaimResponses(description: String) {
        stopMonitoringVaults()
        stopMonitoringSharesAndClaimRequests()
        
        askingForClaims(description: description, callBack: { [weak self] isOk in
            guard let self else { return }
            if isOk {
                self.isLookinForClaimRequests = false
                if self.findClaimResponsesTimer == nil {
                    print("## CLAIM RESPONSES TIMER STARTED")
                    self.findClaimResponsesTimer = Timer.scheduledTimer(timeInterval: Config.timerInterval, target: self, selector: #selector(self.fireClaimResponsesTimer), userInfo: nil, repeats: true)
                }
            } else {
                self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
            }
        })
    }
    
    func stopMonitoringClaimResponses() {
        print("## CLAIM RESPONSES TIMER STOPED")
        findClaimResponsesTimer?.invalidate()
        findClaimResponsesTimer = nil
    }
    
    //MARK: - ADD SECRET SCREEN SPLIT
    func distributeSharesToMembers(_ shares: [AeadCipherText], receiver: UserSignature, description: String, callBack: ((Bool)->())?) {
        for share in shares {
            distribution(encodedShare: share, receiver: receiver, description: description, type: .split, callBack: callBack)
        }
    }
    
    func getVault() {
        isLookinForVaults = true
        print("## findVaultsTimer = \(findVaultsTimer)")
        guard let _ = self.findVaultsTimer else { return }
        
        GetVault().execute() { [weak self] result in
            switch result {
            case .success(let result):
                self?.isLookinForVaults = false
                guard result.msgType == Constants.Common.ok else {
                    self?.alertManager.showCommonError(result.error ?? "")
                    return
                }
                
                print("## GOT VAULT")
                self?.userService.mainVault = result.data?.vault
                self?.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Devices])
            case .failure(let error):
                self?.alertManager.showCommonError(error.localizedDescription)
            }
        }
    }
    
    func reDistribute() {
        guard let signatures = userService.mainVault?.signatures else {
            nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
            return
        }
        let allSecrets = dbManager.getAllSecrets()
        let myGroup = DispatchGroup()
        var results = [Bool]()
        
        for secret in allSecrets {
            myGroup.enter()
            
            let sharesArray = Array(secret.shares)
            guard let shareString = sharesArray.first,
                  let shareObject: SecretDistributionDoc = try? jsonManager.objectGeneration(from: shareString),
                  let securityBox = userService.securityBox,
                  let shareStringLast = sharesArray.last,
                  let shareObjectLast: SecretDistributionDoc = try? jsonManager.objectGeneration(from: shareStringLast) else {
                nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
                return
            }
            
            
            let model = RestoreModel(keyManager: securityBox.keyManager, docOne: shareObject, docTwo: shareObjectLast)
            guard let decriptedSecret = rustManager.restoreSecret(model: model) else {
                nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
                return
            }
            let components = rustManager.split(secret: decriptedSecret)
//            dbManager.getAllSecrets()
            sharesManager.distributeShares(components, signatures, description: secret.secretName, callBack: { isOk in
                results.append(isOk)
                myGroup.leave()
            })
        }
        myGroup.notify(queue: .main) { [weak self] in
            guard let _ = results.first(where: {$0 == false}) else {
                self?.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Redistribute])
                return
            }
            self?.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
        }
    }
}

private extension DistributionConnectorManager {
    func checkForError() {
        alertManager.showCommonError(MetaSecretErrorType.cantRestore.message())
        self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
    }
    
    func distributeClaimError() {
        alertManager.showCommonError(MetaSecretErrorType.cantClaim.message())
        isLookinForClaimRequests = false
    }
    
    func askingForClaimError(_ callBack: ((Bool)->())?) {
        callBack?(false)
        alertManager.showCommonError(MetaSecretErrorType.cantRestore.message())
    }
    
    @objc func fireSharesAndClaimRequestsTimer() {
        print("## FIRE!!!")
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
        FindShares().execute { [weak self] result in
            guard let _ = self?.findSharesAndClaimRequestsTimer else { return }
            
            switch result {
            case .success(let result):
                guard result.msgType == Constants.Common.ok, !(result.data?.isEmpty ?? true) else {
                    self?.isLookinForShares = false
                    print("## FIND SHARES ERROR with MSG = \(result.msgType)")
                    return
                }
                
                self?.sharesManager.distribtuteToDB(result.data) { isToReload in
                    print("## NEW SHARES SAVED TO DB")
                    if isToReload {
                        self?.isLookinForShares = false
                        self?.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Shares])
                    }
                }
            case .failure(let error):
                self?.alertManager.showCommonError(error.localizedDescription)
            }
        }
    }
    
    //MARK: - CLAIMS ACTIONS
    @objc func fireClaimResponsesTimer() {
        self.findSharesClaim()
    }
    
    func findSharesClaim() {
        FindShares().execute { [weak self] result in
            guard let _ = self?.findClaimResponsesTimer else { return }
            
            switch result {
            case .success(let result):
                guard result.msgType == Constants.Common.ok, let shares = result.data, !shares.isEmpty else {
                    print("## !!!!!!!!!!!!! EMPTY !!!!!!!!!!!!!!!!!")
                    self?.checkForError()
                    return
                }
                
                guard let share = shares.first,
                      share.distributionType == .recover,
                      let keyManager = self?.securityBox?.keyManager,
                      let description = share.metaPassword?.metaPassword.id.name,
                      let secret = DBManager.shared.readSecretBy(description: description),
                      let secretShareString = secret.shares.first,
                      let docOne: SecretDistributionDoc = self?.objectGeneration(from: secretShareString)
                else {
                    self?.checkForError()
                    return
                }

                self?.stopMonitoringClaimResponses()
                let model = RestoreModel(keyManager: keyManager, docOne: docOne, docTwo: share)
                let decriptedSecret = RustTransporterManager().restoreSecret(model: model)
                print("## DECRYPTED \(decriptedSecret ?? "FATALITY")")
                self?.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Claims(decriptedSecret)])
                
            case .failure(_):
                self?.showCommonError(MetaSecretErrorType.cantRestore.message())
                self?.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
            }
        }
    }
    
    func askingForClaims(description: String, callBack: ((Bool)->())?) {
        guard let userSignature = userService.userSignature, let secret = dbManager.readSecretBy(description: description) else {
            askingForClaimError(callBack)
            return
        }

        let sharesArray = Array(secret.shares)
        
        guard let shareString = sharesArray.first,
              let shareObject: SecretDistributionDoc = try? jsonManager.objectGeneration(from: shareString),
              let members = shareObject.metaPassword?.metaPassword.vault.signatures
        else {
            askingForClaimError(callBack)
            return
        }
        
        if sharesArray.count != 1,
           let securityBox = userService.securityBox,
           let shareString = sharesArray.last,
           let shareObjectLast: SecretDistributionDoc = try? jsonManager.objectGeneration(from: shareString)
        {
            let model = RestoreModel(keyManager: securityBox.keyManager, docOne: shareObject, docTwo: shareObjectLast)
            let decriptedSecret = rustManager.restoreSecret(model: model)
            nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Claims(decriptedSecret)])
            return
        }
        
        let myGroup = DispatchGroup()
        var results = [Bool]()
        
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
                        print("## CLAIM RESPONSE FAILED and MSG = \(result.msgType ?? "")")
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
                    print("## CLAIM RESPONSE FAILED")
                    self?.alertManager.showCommonError(error.localizedDescription)
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
        
        FindClaims().execute { [weak self] result in
            guard let _ = self?.findSharesAndClaimRequestsTimer else { return }
            
            switch result {
            case .success(let result):
                guard result.msgType == Constants.Common.ok, !(result.data?.isEmpty ?? true) else {
                    self?.isLookinForClaimRequests = false
                    print("## == NO CLAIM REQUESTS FOR \(self?.userService.userSignature?.device.deviceName ?? "") ==")
                    return
                }
                self?.alertManager.showCommonError("I GOT IT! I'LL SEND!")
                self?.distributeClaimsToRestore(claims: result.data)
            case .failure(let error):
                self?.isLookinForClaimRequests = false
                self?.alertManager.showCommonError(error.localizedDescription)
            }
        }
        
    }
    
    func distributeClaimsToRestore(claims: [PasswordRecoveryRequest]?) {
        guard let claims else {
            distributeClaimError()
            return
        }

        #warning("Now we supose we have only one claim, but in future we could have a few")
        for claim in claims {
            var newEncryptedshare: AeadCipherText? = nil
            var secretDoc: SecretDistributionDoc? = nil
            
            
            guard let description = claim.id.name,
                  let secret = dbManager.readSecretBy(description: description),
                  let encryptedShare = secret.shares.first else {
                distributeClaimError()
                return
            }
            
            secretDoc = try? jsonManager.objectGeneration(from: encryptedShare)
            let chanel = secretDoc?.secretMessage?.encryptedText.authData.channel
            
            if claim.consumer.transportPublicKey.base64Text == chanel?.receiver.base64Text ||
                claim.consumer.transportPublicKey.base64Text == chanel?.sender.base64Text {
                newEncryptedshare = secretDoc?.secretMessage?.encryptedText
            } else {
                guard let secretDoc,
                      let keyManager = userService.securityBox?.keyManager,
                      let userShareDto = rustManager.decrypt(model: DecryptModel(keyManager: keyManager, doc: secretDoc)) else {
                    distributeClaimError()
                    return
                }
                
                newEncryptedshare = rustManager.encrypt(share: ShareToEncrypt(senderKeyManager: keyManager, receiverPubKey: claim.consumer.transportPublicKey, secret: userShareDto))
            }
            
            guard let encryptedShare = newEncryptedshare else {
                distributeClaimError()
                return
            }
            
            distribution(encodedShare: encryptedShare, receiver: claim.consumer, description: description, type: .recover, callBack: { [weak self] _ in
                self?.isLookinForClaimRequests = false
            })
        }
    }
    
    //MARK: - VAULTS ACTIONS
    @objc func fireVaultsTimer() {
        print("## FIRE 2!!!")
        if !isLookinForVaults {
            getVault()
        }
    }
    
    //MARK: - DISTRIBUTE ACTIONS
    func distribution(encodedShare: AeadCipherText, receiver: UserSignature, description: String, type: SecretDistributionType, callBack: ((Bool)->())?) {
        Distribute(encodedShare: encodedShare, receiver: receiver, description: description, type: type).execute() { [weak self] result in
            switch result {
            case .failure(let err):
                self?.alertManager.showCommonError(err.localizedDescription)
                callBack?(false)
            case .success(let result):
                if result.msgType != Constants.Common.ok {
                    self?.alertManager.showCommonError(result.error)
                }
                print("## I'VE SENT SUCCESSFULY to \(receiver.device.deviceName)")
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
    case Redistribute
}
