//
//  MetaSecretErrors.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 17.11.2022.
//

import Foundation

enum MetaSecretErrorType {
    case generateUser
    case distribute
    case restore
    
    func message() -> String {
        switch self {
        case .generateUser:
            return Constants.Errors.generateUserError
        case .distribute:
            return Constants.Errors.distributeError
        case .restore:
            return Constants.Errors.restoreError
        }
    }
}
