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
    }
    
    struct MainScreen {
        static let title = "MetaSecret"
        static let joinPendings = "You have some devices waiting for your approve! Do you wanna accept?"
        static let ok = "Accept"
        static let cancel = "Decline"
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
    }
    
    //MARK: - TAGS
    struct ViewTags {
        static let loaderTag = 1001
    }
}
