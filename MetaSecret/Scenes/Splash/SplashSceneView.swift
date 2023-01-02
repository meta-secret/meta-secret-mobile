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
    
    //MARK: - INITIALISATION
    init(messagesManager: Alertable,
         router: ApplicationRouterProtocol
    ) {
        self.router = router
        super.init(alertManager: messagesManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        router.route()
    }
}
