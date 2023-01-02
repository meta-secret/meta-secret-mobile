//
//  MetaSecretErrors.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 17.11.2022.
//

import Foundation

enum MetaSecretErrorType: Error {
    case commonError
    case generateUser
    case distribute
    case restore
    case objectToJson
    case cantRestore
    case cantClaim
    case declinedUser
    
    func message() -> String {
        switch self {
        case .commonError:
            return Constants.Errors.commonError
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
        }
    }
}
