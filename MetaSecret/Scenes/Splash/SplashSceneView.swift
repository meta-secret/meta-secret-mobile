//
//  SplashSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import UIKit

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
        biometricManager.canEvaluate { [weak self] (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                self?.router.route()
                return
            }
            
            biometricManager.evaluate { [weak self] (success, error) in
                guard success else {
                    self?.alertManager.showCommonAlert(AlertModel(title: Constants.Errors.error,
                                message: error?.localizedDescription ?? Constants.BiometricError.unknown, cancelButton: nil))
                    return
                }
                
                self?.router.route()
            }
        }
    }
}
