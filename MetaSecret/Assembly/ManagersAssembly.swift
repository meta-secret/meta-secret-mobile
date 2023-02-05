//
//  ManagersAssembly.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.12.2022.
//

import Swinject
import SwinjectAutoregistration

class ManagersAssembly: Assembly {
    func assemble(container: Container) {
        container.autoregister(UIFactoryProtocol.self, initializer: UIFactory.init)
        container.autoregister(ApplicationRouterProtocol.self, initializer: ApplicationRouter.init).inObjectScope(.container)
        container.autoregister(Alertable.self, initializer: AlertManager.init).inObjectScope(.container)
        container.autoregister(RootFindable.self, initializer: RootControllerManager.init).inObjectScope(.container)
        container.autoregister(UsersServiceProtocol.self, initializer: UsersService.init).inObjectScope(.container)
        container.autoregister(Signable.self, initializer: SigningManager.init).inObjectScope(.container)
        container.autoregister(DBManagerProtocol.self, initializer: DBManager.init).inObjectScope(.container)
        container.autoregister(RustProtocol.self, initializer: RustTransporterManager.init).inObjectScope(.container)
        container.autoregister(JsonSerealizable.self, initializer: JsonSerealizManager.init).inObjectScope(.container)
        container.autoregister(DistributionProtocol.self, initializer: DistributionManager.init).inObjectScope(.container)
        container.autoregister(BiometricsManagerProtocol.self, initializer: BiometricsManager.init).inObjectScope(.container)
    }
}
