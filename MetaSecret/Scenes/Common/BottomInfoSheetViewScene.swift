//
//  BottomInfoSheetViewScene.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 10.09.2022.
//

import UIKit

class BottomInfoSheetViewScene: CommonSceneView {
    //MARK: - IBOutlets
    @IBOutlet weak var topOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var mainBG: UIView!
    
    var model: BottomInfoSheetModel? = nil
    
    //MARK: - Properties
    private struct Config {
        static let bgAlpha: CGFloat = 0.4
        static let cornerRadius = 16
    }
    
    //MARK: - Lifecycle
    override func setupUI() {
        internalSetupUI()
    }
    
    //MARK: - IBActions
    @IBAction func closeTapped(sender: UIButton) {
        closeHint()
    }
}

private extension BottomInfoSheetViewScene {
    func internalSetupUI() {
        infoContainer.roundCorners(corners: [.topLeft, .topRight], radius: Config.cornerRadius)
        
        titleLabel.text = model?.title
        infoTextLabel.text = model?.message
        titleLabel.sizeToFit()
        infoTextLabel.sizeToFit()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Common.animationTime) { [weak self] in
            self?.showHint()
        }
    }
    
    func showHint() {
        topOffsetConstraint.constant = infoContainer.frame.height
        self.mainBG.alpha = Config.bgAlpha
        UIView.animate(withDuration: Constants.Common.animationTime) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: true)
        }
    }
    
    func closeHint() {
        topOffsetConstraint.constant = 0
        self.mainBG.alpha = 0
        UIView.animate(withDuration: Constants.Common.animationTime) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: true)
        }

    }
}
