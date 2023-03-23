//
//  SplashSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import UIKit
import PromiseKit

class SplashSceneView: CommonSceneView {
    //MARK: - OUTLETS
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - PROPERTIES
    private let router: ApplicationRouterProtocol
    private var isSecureAuth = false
    private let biometricManager: BiometricsManagerProtocol
    
    //MARK: - INITIALISATION
    init(messagesManager: Alertable,
         biometricManager: BiometricsManagerProtocol,
         router: ApplicationRouterProtocol
    ) {
        self.router = router
        self.biometricManager = biometricManager
        super.init(alertManager: messagesManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        checkBiometric()
    }
    
    private func checkBiometric() {
        let _ = firstly {
            biometricManager.canEvaluate()
        }.get { canEvaluate in
            guard canEvaluate else {
                self.router.route()
                return
            }
        }.then { _ in
            self.biometricManager.evaluate()
        }.get { success, error in
            guard success else {
                self.alertManager.showCommonAlert(AlertModel(title: Constants.Errors.error,
                                                             message: error?.localizedDescription ?? Constants.BiometricError.unknown, cancelButton: nil, okHandler: {
                    if error == BiometricError.userCancel {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }))
                return
            }
            
            self.router.route()
        }
    }
}
