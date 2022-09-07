//
//  Constants.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation

struct Constants {
    
    //MARK: - LOGIN
    struct LoginScreen {
        static let title = "MetaSecret"
        static let userNameLabel = "Your user name"
        static let letsGoButton = "Let's go"
        static let alreadyExisted = "We found this name is already existed. Is it yours? Please pair your devices"
        static let renameYourAccount = "We found this name is already existed. You can pair it on your main device or choose another name. Do you wanna choose another one?"
        static let renameOk = "Rename"
        static let declined = "This name is already taken. And user declined your request. Please rename your Vault."
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
