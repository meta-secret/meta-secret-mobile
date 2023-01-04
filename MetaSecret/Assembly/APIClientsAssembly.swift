//
//  APIClientsAssembly.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 30.12.2022.
//

import Swinject
import SwinjectAutoregistration

class APIClientsAssembly: Assembly {
    func assemble(container: Container) {
        container.autoregister(APIManagerProtocol.self, initializer: APIManager.init)
        container.autoregister(AuthorizationProtocol.self, initializer: AuthorisationService.init)
        container.autoregister(VaultAPIProtocol.self, initializer: VaultAPIService.init)
        container.autoregister(ShareAPIProtocol.self, initializer: ShareAPIService.init)
    }
}

