//
//  FindSharesRequest.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.01.2023.
//

import Foundation

final class FindSharesRequest: BaseModel {
    var userRequestType: SecretDistributionType
    var userSignature: UserSignature
    
    init(userRequestType: SecretDistributionType, userSignature: UserSignature) {
        self.userRequestType = userRequestType
        self.userSignature = userSignature
    }
}
