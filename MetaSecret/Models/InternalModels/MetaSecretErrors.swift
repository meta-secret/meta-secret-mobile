//
//  MetaSecretErrors.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 17.11.2022.
//

import Foundation

enum MetaSecretErrorType: Error {
    case commonError
    case networkError
    case registerError
    case splitError
    case vaultError
    case shareSearchError
    case distributionDBError
    case userSignatureError
    case generateUser
    case distribute
    case restore
    case objectToJson
    case cantRestore
    case cantClaim
    case declinedUser
    case alreadySavedMessage
    case notConfirmed
    
    func message() -> String {
        switch self {
        case .commonError:
            return Constants.Errors.commonError
        case .networkError:
            return Constants.Errors.networkError
        case .registerError:
            return Constants.Errors.registerError
        case .vaultError:
            return Constants.Errors.vaultError
        case .userSignatureError:
            return Constants.Errors.userSignatureError
        case .generateUser:
            return Constants.Errors.generateUserError
        case .distribute:
            return Constants.Errors.distributeError
        case .restore:
            return Constants.Errors.restoreError
        case .objectToJson:
            return Constants.Errors.objectToJsonError
        case .cantRestore:
            return Constants.Errors.cantRestore
        case .cantClaim:
            return Constants.Errors.cantClaim
        case .declinedUser:
            return Constants.LoginScreen.declined
        case .shareSearchError:
            return Constants.Errors.shareSearchError
        case .distributionDBError:
            return Constants.Errors.distributionDBError
        case .splitError:
            return Constants.Errors.splitError
        case .alreadySavedMessage:
            return Constants.AddSecret.alreadySavedMessage
        case .notConfirmed:
            return Constants.Errors.notConfirmed
        }
    }
}
