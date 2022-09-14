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
    }
    
    //MARK: - LOGIN
    struct LoginScreen {
        static let title = "MetaSecret"
        static let userNameLabel = "Your user name"
        static let letsGoButton = "LET'S GO"
        static let alreadyExisted = "We found this name is already existed. Would you like to join the cluster?"
        static let renameYourAccount = "We found this name is already existed. You can pair it on your main device or choose another name. Do you wanna choose another one?"
        static let renameOk = "Rename"
        static let declined = "This name is already taken. And user declined your request. Please rename your Vault."
        static let awaitingTitle = "This device is awaiting for approval!"
        static let awaitingTitleBoldComponents = ["device", "awaiting"]
        static let awaitingMessage = "This device is awaiting for approval on your main device. Please, launch the app on the first device and accept joining request of this device."
    }
    
    struct MainScreen {
        static let secrets = "Secrets"
        static let devices = "Devices"
        static let joinPendings = "You have some devices waiting for your approve! Do you wanna accept?"
        static let ok = "Accept"
        static let cancel = "Decline"
        static let pendingTitle = "Pending"
        static let declineTitle = "Declined"
        static let memberTitle = "Member"
        static let noSecrets = "There are no Secrets YET! Comming SOON!"
        static let noDevices = "Hmmmm.... no devices... are you magician?"
        static let titleFirstTimeHintBoldComponents = ["cluster", "keep", "securely"]
        static let titleFirstTimeHint = "Create your cluster to keep secrets securely."
        static let messageFirstTimeHint = "Only once device registered! \n• If you lose this device you will lose all your secrets. As a best practice, we recommend you assign multiple devices to be able to use our recovery mechanism. \n• Just install this application on two more devices and enter the SAME account name. Virtual magic will store your ENCRYPTED secrets on three different devices. \n• Undeline We'll create virtual devices for you, you don't need to worry about technical details this piece of work on us. It's not safe as it could be."
        static let virtual = "Virtual"
        static func addDevices(memberCounts: Int) -> String {
            let neededDevicesCount = 3 - memberCounts
            return "Please, install this app on \(neededDevicesCount) more devices for better security!"
        }
    }
    
    struct Devices {
        static let istallInstructionTitle = "How to add remote additional device?"
        static let istallInstruction = "1. On your new device download the app: MetaSecret or Open https://comingSoon.com \n\n2. On your new device: Chose Already taken name \n\n 3. On this device and this screen you will see your new device. Just select it and approve. \n\n4. Repeat it for one more device. Here we go! You created your own cluster"
    }
    
    struct PairingDeveice {
        static let title = "Device adding"
    }
    
    struct AddSecret {
        static let title = "Add a secret"
    }
    
    //MARK: - ALERTS
    struct Alert {
        static let emptyTitle = ""
        static let ok = "Ok"
        static let cancel = "Cancel"
    }
    
    struct Errors {
        static let error = "Error"
        static let warning = "Warning"
        static let userNameMesasge = "This user name is already taken. Do you wanna login?"
        static let enterName = "Please, enter your name"
        static let swwError = "Something went wrong"
        static let notEnoughtMembers = "You have not enought devices to save your secrets. It would be better to have at least 3 devices in your cluster. Now we can create virtual members on your device. But it's not secure."
    }
    
    //MARK: - TAGS
    struct ViewTags {
        static let loaderTag = 1001
    }
}
