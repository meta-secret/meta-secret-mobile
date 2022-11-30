//
//  SplashSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import UIKit

class SplashSceneView: UIViewController, SplashSceneProtocol, UD, JsonSerealizable {
    //MARK: - OUTLETS
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - PROPERTIES
    private var viewModel: SplashSceneViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        self.viewModel = SplashSceneViewModel(delegate: self)
        viewModel?.chooseStartingScreen()
    }
}
