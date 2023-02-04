//
//  Constants.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit

struct Constants {
    //MARK: - COMMON
    struct Common {
        static let animationTime: CGFloat = 0.3
        static let waitingTime: CGFloat = 0.1
        static let virtual = "virtual"
        static let finishedStatus = "finished"
        static let ok = "ok"
        static let neededMembersCount = 3
        static let timerInterval: CGFloat = 1
    }
    
    //MARK: - ONBOARDING
    struct Onboarding {
        static let welcome = NSLocalizedString("welcome", comment: "")
        static let whatIs = NSLocalizedString("whatIs", comment: "")
        
        static let personalCloud = NSLocalizedString("personalCloud", comment: "")
        static let personalCloudDescription = NSLocalizedString("personalCloudDescription", comment: "")
        
        static let distributedStorage = NSLocalizedString("distributedStorage", comment: "")
        static let distributedStorageDescription = NSLocalizedString("distributedStorageDescription", comment: "")
        
        static let passwordLess = NSLocalizedString("passwordLess", comment: "")
        static let passwordLessDescription = NSLocalizedString("passwordLessDescription", comment: "")
        
        static let backup = NSLocalizedString("backup", comment: "")
        static let backupDescription = NSLocalizedString("backupDescription", comment: "")
        
        static let getStartedButtonTitle = NSLocalizedString("getStarted", comment: "")
    }
    
    //MARK: - LOGIN
    struct LoginScreen {
        static let title = NSLocalizedString("metaSecret", comment: "")
        static let loginTitle = NSLocalizedString("loginTitle", comment: "")
        static let userNameLabel = NSLocalizedString("yourName", comment: "")
        static let letsGoButton = NSLocalizedString("letsgo", comment: "")
        static let alreadyExisted = NSLocalizedString("wannaJoin", comment: "")
        static let renameOk = NSLocalizedString("rename", comment: "")
        static let declined = NSLocalizedString("declinedRequest", comment: "")
        static let awaitingTitle = NSLocalizedString("waitingForApproval", comment: "")
        static let awaitingMessage = NSLocalizedString("pleaseAcceptRequest", comment: "")
        static let chooseAnotherName = NSLocalizedString("pleaseAcceptRequest", comment: "")
    }
    
    struct MainScreen {
        static let secrets = NSLocalizedString("secrets", comment: "")
        static let devices = NSLocalizedString("devices", comment: "")
        static let joinPendings = NSLocalizedString("doYouWannaAccept", comment: "")
        static let ok = NSLocalizedString("accept", comment: "")
        static let cancel = NSLocalizedString("decline", comment: "")
        static let pendingTitle = NSLocalizedString("pending", comment: "")
        static let declineTitle = NSLocalizedString("declined", comment: "")
        static let memberTitle = NSLocalizedString("member", comment: "")
        static let noSecrets = NSLocalizedString("noSecrets", comment: "")
        static let noDevices = NSLocalizedString("hmmm", comment: "")
        static let titleFirstTimeHint = NSLocalizedString("createCluster", comment: "")
        
        static func messageFirstTimeHint(name: String) -> String {
            let localizedString = NSLocalizedString("onlyOneDevice", comment: "")
            let wantedString = String(format: localizedString, name)
            return wantedString
        }
        static func addDevices(memberCounts: Int) -> String {
            let neededDevicesCount = 3 - memberCounts
            let localizedString = NSLocalizedString("pleaseInstall", comment: "")
            let wantedString = String(format: localizedString, "\(neededDevicesCount)")
            
            return wantedString
        }
        static let yourNick = NSLocalizedString("yourNick", comment: "")
        static let yourDevices = NSLocalizedString("yourDevices", comment: "")
        static let yourSecrets = NSLocalizedString("yourSecrets", comment: "")
        static let add = NSLocalizedString("add", comment: "")
        static let notBackedUp = NSLocalizedString("notBackedUp", comment: "")
    }
    
    struct Devices {
        static let member = NSLocalizedString("member", comment: "")
        static let declined = NSLocalizedString("declined", comment: "")
        static let pending = NSLocalizedString("pending", comment: "")
        static let istallInstructionTitle = NSLocalizedString("howToAdd", comment: "")
        static func installInstruction(name: String) -> String {
            return String(format: NSLocalizedString("stepsToAdd", comment: ""), name)
        }
    }
    
    struct PairingDeveice {
        static let title = NSLocalizedString("deviceAdding", comment: "")
        static let accept = NSLocalizedString("accept", comment: "")
        static let decline = NSLocalizedString("decline", comment: "")
        static let warningMessage = NSLocalizedString("pleaseApprove", comment: "")
    }
    
    struct AddSecret {
        static let title = NSLocalizedString("addSecret", comment: "")
        static let titleEdit = NSLocalizedString("editSecret", comment: "")
        static let recoverEdit = NSLocalizedString("recoverEdit", comment: "")
        static let addDescriptionTitle = NSLocalizedString("addDescription", comment: "")
        static let description = NSLocalizedString("description", comment: "")
        static let addPassword = NSLocalizedString("addPassword", comment: "")
        static let password = NSLocalizedString("password", comment: "")
        static let decriptionPlaceHolder = NSLocalizedString("password", comment: "")
        static let splitInstruction = NSLocalizedString("splitInstruction", comment: "")
        static let splitInstructionLocal = NSLocalizedString("splitInstructionLocal", comment: "")
        static let selectSecond = NSLocalizedString("selectSecond", comment: "")
        static let selectThird = NSLocalizedString("selectThird", comment: "")
        static let selectSecondButton = NSLocalizedString("selectSecondButton", comment: "")
        static let selectThirdButton = NSLocalizedString("selectThirdButton", comment: "")
        static let split = NSLocalizedString("split", comment: "")
        static let selectDevice = NSLocalizedString("selectDevice", comment: "")
        static let selectDeviceButton = NSLocalizedString("selectDeviceButton", comment: "")
        static let selectDeviceButtonLocal = NSLocalizedString("selectDeviceButtonLocal", comment: "")
        static let notSplitedMessage = NSLocalizedString("notSplitedMessage", comment: "")
        static let alreadySavedMessage = NSLocalizedString("alreadySavedMessage", comment: "")
        static let edit = NSLocalizedString("edit", comment: "")
        static let showSecret = NSLocalizedString("showSecret", comment: "")
        static let success = NSLocalizedString("success", comment: "")
        static let successSplited = NSLocalizedString("successSplited", comment: "")
    }
    
    struct SelectDevice {
        static let sentShareTitle = NSLocalizedString("sentShareTitle", comment: "")
        static let sentShareMessage = NSLocalizedString("sentShareMessage", comment: "")
        static let chooseDevices = NSLocalizedString("chooseDevices", comment: "")
    }
    
    //MARK: - ALERTS
    struct Alert {
        static let emptyTitle = ""
        static let ok = NSLocalizedString("ok", comment: "")
        static let cancel = NSLocalizedString("cancel", comment: "")
        static let biometricalReason = NSLocalizedString("biometricalReason", comment: "")
        static let needConfirmation = NSLocalizedString("needConfirmation", comment: "")
        static let confirmationText = NSLocalizedString("confirmationText", comment: "")
        static let waitConfirmationText = NSLocalizedString("waitConfirmationText", comment: "")
    }
    
    struct Errors {
        static let error = NSLocalizedString("error", comment: "")
        static let warning = NSLocalizedString("warning", comment: "")
        static let commonError = NSLocalizedString("commonError", comment: "")
        static let networkError = NSLocalizedString("networkError", comment: "")
        static let registerError = NSLocalizedString("registerError", comment: "")
        static let vaultError = NSLocalizedString("vaultError", comment: "")
        static let userSignatureError = NSLocalizedString("userSignatureError", comment: "")
        static let userNameMesasge = NSLocalizedString("wannaLogin", comment: "")
        static let enterName = NSLocalizedString("enterName", comment: "")
        static let swwError = NSLocalizedString("sww", comment: "")
        static let notEnoughtMembers = NSLocalizedString("atLeast3", comment: "")
        static let generateUserError = NSLocalizedString("generateUserError", comment: "")
        static let distributeError = NSLocalizedString("distributeError", comment: "")
        static let restoreError = NSLocalizedString("restoreError", comment: "")
        static let encodeError = NSLocalizedString("encodeError", comment: "")
        static let noMainUserError = NSLocalizedString("noMainUserError", comment: "")
        static let objectToJsonError = NSLocalizedString("objectToJsonError", comment: "")
        static let cantRestore = NSLocalizedString("cantRestore", comment: "")
        static let cantClaim = NSLocalizedString("cantClaim", comment: "")
        static let shareSearchError = NSLocalizedString("shareSearchError", comment: "")
        static let distributionDBError = NSLocalizedString("distributionDBError", comment: "")
        static let splitError = NSLocalizedString("splitError", comment: "")
        static let authError = NSLocalizedString("authError", comment: "")
        static let authErrorMessage = NSLocalizedString("authErrorMessage", comment: "")
        static let notConfirmed = NSLocalizedString("notConfirmed", comment: "")
    }
    
    //MARK: - TAGS
    struct ViewTags {
        static let loaderTag = 1001
    }
}
