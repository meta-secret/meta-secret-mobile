//
//  DistributionConnectorManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.12.2022.
//

import Foundation
import PromiseKit
import RealmSwift

protocol DistributionProtocol {
    func startMonitoringSharesAndClaimRequests()
    func startMonitoringVaults()
    func startMonitoringClaimResponses(descriptionName: String)
    func stopMonitoringClaimResponses()
    func distributeSharesToMembers(_ shares: [UserShareDto], signatures: [UserSignature], descriptionName: String) -> Promise<Void>
    func getVault() -> Promise<Void>
    func findShares(type: SecretDistributionType) -> Promise<Void>
    func reDistribute() -> Promise<Void>
    
    func distributeShares(_ shares: [UserShareDto], _ signatures: [UserSignature], descriptionName: String) -> Promise<Void>
    func distribtuteToDB(_ shares: [SecretDistributionDoc]?) -> Promise<Void>
    func encryptShare(_ share: UserShareDto, _ receiverPubKey: Base64EncodedText) -> AeadCipherText?
}

class DistributionManager: NSObject, DistributionProtocol  {
    //MARK: - PROPERTIES
    fileprivate enum SplittedType: Int {
        case fullySplitted = 3
        case allInOne = 1
        case partially = 2
    }
    
    private var shares: [UserShareDto] = [UserShareDto]()
    private var signatures: [UserSignature] = [UserSignature]()
    private var secretDescription: String = ""
    
    private var findSharesAndClaimRequestsTimer: Timer? = nil
    private var findVaultsTimer: Timer? = nil
    private var findClaimResponsesTimer: Timer? = nil
    
    private var isNeedToRedistribute: Bool = false
    private var isNeedToSearching: Bool = true
    private var needToRecover: Bool = false
    private let nc = NotificationCenter.default
    
    private var userService: UsersServiceProtocol
    private let alertManager: Alertable
    private let jsonManager: JsonSerealizable
    private let dbManager: DBManagerProtocol
    private let rustManager: RustProtocol
    private let vaultService: VaultAPIProtocol
    private let shareService: ShareAPIProtocol
    
    //MARK: - INIT
    init(userService: UsersServiceProtocol, alertManager: Alertable, jsonManager: JsonSerealizable, dbManager: DBManagerProtocol, rustManager: RustProtocol, vaultService: VaultAPIProtocol, shareService: ShareAPIProtocol) {
        self.userService = userService
        self.alertManager = alertManager
        self.jsonManager = jsonManager
        self.dbManager = dbManager
        self.rustManager = rustManager
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
    func startMonitoringClaimResponses(descriptionName: String) {
        firstly {
            askingForClaims(descriptionName: descriptionName)
        }.catch { e in
            let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
            self.alertManager.showCommonError(text)
            self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
        }.finally {
            if self.findClaimResponsesTimer == nil {
                self.findClaimResponsesTimer = Timer.scheduledTimer(timeInterval: Constants.Common.timerInterval, target: self, selector: #selector(self.fireClaimResponsesTimer), userInfo: nil, repeats: true)
            }
        }
    }
    
    func stopMonitoringClaimResponses() {
        findClaimResponsesTimer?.invalidate()
        findClaimResponsesTimer = nil
    }
    
    //MARK: - ADD SECRET SCREEN SPLIT
    func distributeSharesToMembers(_ shares: [UserShareDto], signatures: [UserSignature], descriptionName: String) -> Promise<Void> {
        var promises = [Promise<DistributeResult>]()
        for i in 0..<shares.count {
            let signature: UserSignature
            let shareToEncrypt = shares[i]
            if signatures.count > i {
                signature = signatures[i]
            } else {
                signature = signatures[0]
            }
            
            if let encryptedShare = encryptShare(shareToEncrypt, signature.transportPublicKey) {
                for share in [encryptedShare] {
                    promises.append(distribution(encodedShare: share, receiver: signature, descriptionName: descriptionName, type: .Split))
                }
            }
        }
        
        return firstly {
            when(fulfilled: promises)
        }.then { result in
            self.commonResultHandler(result: result)
        }.asVoid()
    }

    func getVault() -> Promise<Void> {
        return firstly {
            vaultService.getVault(nil)
        }.then { result in
            self.commonResultHandler(result: result)
        }.asVoid()
    }
    
    func findShares(type: SecretDistributionType) -> Promise<Void> {
        return firstly {
            shareService.findShares(type: type)
        }.then { result in
            self.commonResultHandler(result: result)
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
            promises.append(distributeShares(components, signatures, descriptionName: secret.secretName))
        }

        return firstly {
            when(fulfilled: promises)
        }.then { result in
            self.commonResultHandler(result: result)
        }.asVoid()
    }
    
    //MARK: - SHARES DISTRIBUTION
    func distributeShares(_ shares: [UserShareDto], _ signatures: [UserSignature], descriptionName: String) -> Promise<Void> {
        guard let typeOfSharing = SplittedType(rawValue: signatures.count) else {
            return Promise(error: MetaSecretErrorType.distribute)
        }
        
        self.signatures = signatures
        self.shares = shares
        self.secretDescription = descriptionName
        
        switch typeOfSharing {
        case .fullySplitted, .allInOne:
            return simpleDistribution()
        case .partially:
            return partiallyDistribute()
        }
    }
    
    func distribtuteToDB(_ shares: [SecretDistributionDoc]?) -> Promise<Void> {
        guard let shares else {
            return Promise(error: MetaSecretErrorType.distributionDBError)
        }
        let dictionary = shares.reduce(into: [String: [SecretDistributionDoc]]()) { result, object in
            let array = result[object.metaPassword?.metaPassword.id.name ?? "NoN"] ?? []
            result[object.metaPassword?.metaPassword.id.name ?? "NoN"] = array + [object]
        }

        for (descriptionName, shares) in dictionary {
            let filteredShares = shares.filter({$0.distributionType == .Split})
                let newSecret = Secret()
                newSecret.secretName = descriptionName
                newSecret.shares = List<String>()
            let mappedShares = filteredShares.map {jsonManager.jsonStringGeneration(from: $0)}
                for item in mappedShares {
                    newSecret.shares.append(item ?? "")
                }
            dbManager.saveSecret(newSecret)
        }
        
        
        return Promise().asVoid()
    }
    
    func encryptShare(_ share: UserShareDto, _ receiverPubKey: Base64EncodedText) -> AeadCipherText? {
        guard let keyManager = userService.securityBox?.keyManager else {
            alertManager.showCommonError(Constants.Errors.noMainUserError)
            return nil
        }
        
        let shareToEncode = ShareToEncrypt(senderKeyManager: keyManager, receiverPubKey: receiverPubKey, secret: jsonManager.jsonStringGeneration(from: share) ?? "")
        
        guard let encryptedShare = rustManager.encrypt(share: shareToEncode) else {
            alertManager.showCommonError(Constants.Errors.encodeError)
            return nil
        }
        
        return encryptedShare
    }
}

private extension DistributionManager {
    func checkSharesResult(_ result: FindSharesResult) -> Promise<Void> {
        guard result.msgType == Constants.Common.ok,
              let shares = result.data?.shares,
              !(shares.isEmpty),
              result.data?.userRequestType == .Split else {
            return Promise().asVoid()
        }
        
        return firstly {
            distribtuteToDB(result.data?.shares)
        }.get {
            self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Shares])
        }.asVoid()
    }
    
    func checkForError() {
        alertManager.showCommonError(MetaSecretErrorType.cantRestore.message())
        self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
    }
    
    func distributeClaimError() {
        alertManager.showCommonError(MetaSecretErrorType.distribute.message())
    }
    
    @objc func fireSharesAndClaimRequestsTimer() {
        findClaims()
        let _ = findShares(type: .Split)
    }
    
    //MARK: - CLAIMS ACTIONS
    @objc func fireClaimResponsesTimer() {
        firstly {
            findSharesClaim()
        }.catch {e in
            let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
            self.alertManager.showCommonError(text)
            self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Failure])
            
        }
    }
    
    func findSharesClaim() -> Promise<Void> {
        needToRecover = true
        return firstly {
            shareService.findShares(type: .Recover)
        }.then { result in
            self.commonResultHandler(result: result)
        }
    }
    
    func handleClaimSharesResponse(_ result: FindSharesResult) -> Promise<Void> {
        guard isNeedToSearching else { return Promise().asVoid() }

        guard result.msgType == Constants.Common.ok,
              let shares = result.data?.shares, !shares.isEmpty,
              shares.first?.distributionType == .Recover else {
            return Promise().asVoid()
        }
        
        guard let share = shares.first,
              share.distributionType == .Recover,
              let keyManager = userService.securityBox?.keyManager,
              let descriptionName = share.metaPassword?.metaPassword.id.name,
              let secret = dbManager.readSecretBy(descriptionName: descriptionName),
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
    
    func commonShareChecking(_ result: FindSharesResult) -> Promise<Void> {
        guard result.msgType == Constants.Common.ok else {
            return Promise(error: MetaSecretErrorType.shareSearchError)
        }
        
        guard let data = result.data else {
            return Promise().asVoid()
        }
        
        let type = data.shares.isEmpty ? data.userRequestType : data.shares.first?.distributionType
        
        switch type {
        case .Recover:
            stopMonitoringClaimResponses()
            if userService.mainVault?.signatures?.count == 3, data.shares.isEmpty {
                if needToRecover {
                    needToRecover = false
                    return Promise(error: MetaSecretErrorType.cantClaim)
                } else {
                    needToRecover = false
                    return Promise().asVoid()
                }
            }
            return handleClaimSharesResponse(result)
        case .Split:
            if data.shares.isEmpty {
                return Promise().asVoid()
            }
            return checkSharesResult(result)
        case .none:
            return Promise().asVoid()
        }
    }
    
    func askingForClaims(descriptionName: String) -> Promise<Void> {
        guard let userSignature = userService.userSignature, let secret = dbManager.readSecretBy(descriptionName: descriptionName) else {
            return Promise(error: MetaSecretErrorType.commonError)
        }

        let sharesArray = Array(secret.shares)
        
        isNeedToSearching = sharesArray.count != Constants.Common.neededMembersCount
        
        guard let shareString = sharesArray.first,
              let shareObject: SecretDistributionDoc = try? jsonManager.objectGeneration(from: shareString),
              let members = shareObject.metaPassword?.metaPassword.vault.signatures
        else {
            return Promise(error: MetaSecretErrorType.commonError)
        }
        
        if sharesArray.count != 1,
           let securityBox = userService.securityBox,
           let shareString = sharesArray.last,
           let shareObjectLast: SecretDistributionDoc = try? jsonManager.objectGeneration(from: shareString)
        {
            stopMonitoringClaimResponses()
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

        return firstly {
            when(fulfilled: promises)
        }.then { result in
            self.commonResultHandler(result: result)
        }.asVoid()
    }
    
    func findClaims() {
        let _ = firstly {
            shareService.findClaims()
        }.get { result in
            let _ = self.commonResultHandler(result: result)
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

            guard let name = claim.id.name,
                  let secret = dbManager.readSecretBy(descriptionName: name),
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

            let _ = distribution(encodedShare: encryptedShare, receiver: claim.consumer, descriptionName: name, type: .Recover)
        }
    }
    
    //MARK: - VAULTS ACTIONS
    @objc func fireVaultsTimer() {
        let _ = getVault()
    }
    
    //MARK: - DISTRIBUTE ACTIONS
    func distribution(encodedShare: AeadCipherText, receiver: UserSignature, descriptionName: String, type: SecretDistributionType) -> Promise<DistributeResult> {
        return shareService.distribute(encodedShare: encodedShare, receiver: receiver, descriptionName: descriptionName, type: type)
    }
    
    func handleDistributionResult(_ result: DistributeResult) -> Promise<Void> {
        guard result.msgType == Constants.Common.ok else {
            return Promise(error: MetaSecretErrorType.distribute)
        }
        return Promise().asVoid()
    }
}

private extension DistributionManager {
    //MARK: - DISTRIBUTIONS FLOWS
    func simpleDistribution() -> Promise<Void>{
        return distributeSharesToMembers(shares, signatures: signatures, descriptionName: secretDescription)
    }

    func partiallyDistribute() -> Promise<Void> {
        guard let lastShare = shares.last else { return Promise(error: MetaSecretErrorType.commonError) }
        shares.append(lastShare)
        signatures.append(contentsOf: signatures)

        return simpleDistribution()
    }
}

private extension DistributionManager {
    func commonResultHandler<T>(result: T) -> Promise<Void> {
        switch result {
        case is DistributeResult:
            return self.handleDistributionResult(result as! DistributeResult)
        case is GetVaultResult:
            self.userService.mainVault = (result as! GetVaultResult).data?.vault
            self.nc.post(name: NSNotification.Name(rawValue: "distributionService"), object: nil, userInfo: ["type": CallBackType.Devices])
            return Promise().asVoid()
        case is FindSharesResult:
            return self.commonShareChecking(result as! FindSharesResult)
        case is FindClaimsResult:
            let result = result as! FindClaimsResult
            if result.msgType == Constants.Common.ok, !(result.data?.isEmpty ?? true) {
                self.distributeClaimsToRestore(claims: result.data)
            }
            return Promise().asVoid()
        case is [DistributeResult]:
            return Promise().asVoid()
        case is ClaimResult:
            return Promise().asVoid()
        default:
            return Promise().asVoid()
        }
    }
}

enum CallBackType {
    case Shares
    case Devices
    case Claims(String?)
    case Failure
}
