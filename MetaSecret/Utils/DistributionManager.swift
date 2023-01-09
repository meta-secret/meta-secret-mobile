//
//  DistributionConnectorManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.12.2022.
//

import Foundation
import PromiseKit

protocol DistributionProtocol {
    func startMonitoringSharesAndClaimRequests()
    func startMonitoringVaults()
    func startMonitoringClaimResponses(description: String)
    func stopMonitoringClaimResponses()
    func distributeSharesToMembers(_ shares: [AeadCipherText], receiver: UserSignature, description: String) -> Promise<Void>
    func getVault() -> Promise<Void>
    func findShares() -> Promise<Void>
    func reDistribute() -> Promise<Void>
}

class DistributionManager: NSObject, DistributionProtocol  {
    //MARK: - PROPERTIES
    private var findSharesAndClaimRequestsTimer: Timer? = nil
    private var findVaultsTimer: Timer? = nil
    private var findClaimResponsesTimer: Timer? = nil
    private var isToStopClaimSearching: Bool = false
    
    private var isNeedToRedistribute: Bool = false
    private let nc = NotificationCenter.default
    
    private var userService: UsersServiceProtocol
    private let alertManager: Alertable
    private let jsonManager: JsonSerealizable
    private let dbManager: DBManagerProtocol
    private let rustManager: RustProtocol
    private let sharesManager: SharesProtocol
    private let vaultService: VaultAPIProtocol
    private let shareService: ShareAPIProtocol
    
    //MARK: - INIT
    init(userService: UsersServiceProtocol, alertManager: Alertable, jsonManager: JsonSerealizable, dbManager: DBManagerProtocol, rustManager: RustProtocol, sharesManager: SharesProtocol, vaultService: VaultAPIProtocol, shareService: ShareAPIProtocol) {
        self.userService = userService
        self.alertManager = alertManager
        self.jsonManager = jsonManager
        self.dbManager = dbManager
        self.rustManager = rustManager
        self.sharesManager = sharesManager
        self.vaultService = vaultService
        self.shareService = shareService
    }
    
    //MARK: - MAIN SCREEN. SHARES
    ///This method for monitoring on MianScreen Secrets tab
    func startMonitoringSharesAndClaimRequests() {
        if findSharesAndClaimRequestsTimer == nil {
            findSharesAndClaimRequestsTimer = Timer.scheduledTimer(timeInterval: Constants.Common.timerInterval, target: self, selector: #selector(fireSharesAndClaimRequestsTimer), userInfo: nil, repeats: true)
        }
    }
    
    //MARK: - MAIN SCREEN. VAULTS
    func startMonitoringVaults() {
        if findVaultsTimer == nil {
            findVaultsTimer = Timer.scheduledTimer(timeInterval: Constants.Common.timerInterval, target: self, selector: #selector(fireVaultsTimer), userInfo: nil, repeats: true)
        }
    }
    
    //MARK: - ADD SECRET SCREEN. CLAIMS
    func startMonitoringClaimResponses(description: String) {
        firstly {
            askingForClaims(description: description)
        }.catch { e in
            let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
            self.alertManager.showCommonError(text)
            self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
        }.finally {
            if self.findClaimResponsesTimer == nil, !self.isToStopClaimSearching {
                self.findClaimResponsesTimer = Timer.scheduledTimer(timeInterval: Constants.Common.timerInterval, target: self, selector: #selector(self.fireClaimResponsesTimer), userInfo: nil, repeats: true)
            }
        }
    }
    
    func stopMonitoringClaimResponses() {
        isToStopClaimSearching = true
        findClaimResponsesTimer?.invalidate()
        findClaimResponsesTimer = nil
    }
    
    //MARK: - ADD SECRET SCREEN SPLIT
    func distributeSharesToMembers(_ shares: [AeadCipherText], receiver: UserSignature, description: String) -> Promise<Void> {
        for share in shares {
            return distribution(encodedShare: share, receiver: receiver, description: description, type: .split)
        }
        return Promise().asVoid()
    }
    
    func getVault() -> Promise<Void> {
        return firstly {
            vaultService.getVault()
        }.get { result in
            self.userService.mainVault = result.data?.vault
            self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Devices])
            
        }.asVoid()
    }
    
    func findShares() -> Promise<Void> {
        return firstly {
            shareService.findShares()
        }.then { result in
            self.checkSharesResult(result: result)
        }.asVoid()
    }
    
    func reDistribute() -> Promise<Void> {
        guard let signatures = userService.mainVault?.signatures else {
            return Promise(error: MetaSecretErrorType.distribute)
        }
        let allSecrets = dbManager.getAllSecrets()
        var promises = [Promise<Void>]()
        
        for secret in allSecrets {
            let sharesArray = Array(secret.shares)
            guard let shareString = sharesArray.first,
                  let shareObject: SecretDistributionDoc = try? jsonManager.objectGeneration(from: shareString),
                  let securityBox = userService.securityBox,
                  let shareStringLast = sharesArray.last,
                  let shareObjectLast: SecretDistributionDoc = try? jsonManager.objectGeneration(from: shareStringLast) else {
                return Promise(error: MetaSecretErrorType.distribute)
            }
            
            let model = RestoreModel(keyManager: securityBox.keyManager, docOne: shareObject, docTwo: shareObjectLast)
            guard let decriptedSecret = rustManager.restoreSecret(model: model) else {
                return Promise(error: MetaSecretErrorType.distribute)
            }
            let components = rustManager.split(secret: decriptedSecret)
            promises.append(sharesManager.distributeShares(components, signatures, description: secret.secretName))
        }

        return when(fulfilled: promises)
    }
}

private extension DistributionManager {
    func checkSharesResult(result: FindSharesResult) -> Promise<Void> {
        guard result.msgType == Constants.Common.ok, !(result.data?.isEmpty ?? true) else {
            return Promise().asVoid()
        }
        
        return firstly {
            sharesManager.distribtuteToDB(result.data)
        }.get {
            self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Shares])
        }.asVoid()
    }
    
    func checkForError() {
        alertManager.showCommonError(MetaSecretErrorType.cantRestore.message())
        self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
    }
    
    func distributeClaimError() {
        alertManager.showCommonError(MetaSecretErrorType.cantClaim.message())
    }
    
    @objc func fireSharesAndClaimRequestsTimer() {
        findClaims()
        findShares()
    }
    
    //MARK: - SHARES ACTIONS
    
    //MARK: - CLAIMS ACTIONS
    @objc func fireClaimResponsesTimer() {
        findSharesClaim()
    }
    
    func findSharesClaim() -> Promise<Void> {
        return firstly {
            shareService.findShares()
        }.then { result in
            self.handlefindSharesResponse(result)
        }
    }
    
    func handlefindSharesResponse(_ result: FindSharesResult) -> Promise<Void> {
        guard result.msgType == Constants.Common.ok,
              let shares = result.data,
              !shares.isEmpty else {
            self.checkForError()
            return Promise(error: MetaSecretErrorType.shareSearchError)
        }
        
        guard let share = shares.first,
              share.distributionType == .recover,
              let keyManager = userService.securityBox?.keyManager,
              let description = share.metaPassword?.metaPassword.id.name,
              let secret = dbManager.readSecretBy(description: description),
              let secretShareString = secret.shares.first,
              let docOne: SecretDistributionDoc = try? jsonManager.objectGeneration(from: secretShareString)
        else {
            checkForError()
            return Promise(error: MetaSecretErrorType.shareSearchError)
        }

        let model = RestoreModel(keyManager: keyManager, docOne: docOne, docTwo: share)
        let decriptedSecret = rustManager.restoreSecret(model: model)
        nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Claims(decriptedSecret)])
        return Promise().asVoid()
    }
    
    func askingForClaims(description: String) -> Promise<Void> {
        guard let userSignature = userService.userSignature, let secret = dbManager.readSecretBy(description: description) else {
            return Promise(error: MetaSecretErrorType.cantClaim)
        }

        let sharesArray = Array(secret.shares)
        
        guard let shareString = sharesArray.first,
              let shareObject: SecretDistributionDoc = try? jsonManager.objectGeneration(from: shareString),
              let members = shareObject.metaPassword?.metaPassword.vault.signatures
        else {
            return Promise(error: MetaSecretErrorType.cantClaim)
        }
        
        if sharesArray.count != 1,
           let securityBox = userService.securityBox,
           let shareString = sharesArray.last,
           let shareObjectLast: SecretDistributionDoc = try? jsonManager.objectGeneration(from: shareString)
        {
            let model = RestoreModel(keyManager: securityBox.keyManager, docOne: shareObject, docTwo: shareObjectLast)
            let decriptedSecret = rustManager.restoreSecret(model: model)
            nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Claims(decriptedSecret)])
            return Promise().asVoid()
        }
        
        var promises = [Promise<ClaimResult>]()
        let otherDevices = members.filter({ $0.signature != userSignature.signature})
        let otherMembers = otherDevices.isEmpty ? [userSignature] : otherDevices
        
        for member in otherMembers {
            promises.append(shareService.requestClaim(provider: member, secret: secret))
        }

        return when(fulfilled: promises).asVoid()
    }
    
    func findClaims() {
        firstly {
            shareService.findClaims()
        }.get { result in
            if result.msgType == Constants.Common.ok, !(result.data?.isEmpty ?? true) {
                self.distributeClaimsToRestore(claims: result.data)
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
            
            distribution(encodedShare: encryptedShare, receiver: claim.consumer, description: description, type: .recover)
        }
    }
    
    //MARK: - VAULTS ACTIONS
    @objc func fireVaultsTimer() {
        getVault()
    }
    
    //MARK: - DISTRIBUTE ACTIONS
    func distribution(encodedShare: AeadCipherText, receiver: UserSignature, description: String, type: SecretDistributionType) -> Promise<Void> {
        
        return firstly {
            shareService.distribute(encodedShare: encodedShare, receiver: receiver, description: description, type: type)
        }.then { result in
            self.handleDistributionResult(result)
        }.asVoid()
    }
    
    func handleDistributionResult(_ result: DistributeResult) -> Promise<Void> {
        guard result.msgType == Constants.Common.ok else {
            return Promise(error: MetaSecretErrorType.distribute)
        }
        return Promise().asVoid()
    }
    
}

enum CallBackType {
    case Shares
    case Devices
    case Claims(String?)
    case Failure
}
