//
//  PopupHintViewScene.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 12.09.2022.
//

import UIKit

class PopupHintViewScene: CommonSceneView {

    //MARK: - OUTLETS
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    //MARK: - PROPERTIES
    private struct Config {
        static let cornerRadius = 16
    }
    
    private var callBack: (()->())?
    var model: BottomInfoSheetModel? = nil
    
    //MARK: - LIFE CYCLE
    override init(alertManager: Alertable) {
        super.init(alertManager: alertManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        internalSetupUI()
    }
    
    //MARK: - UBACTION
    @IBAction func closeTapped(_ sender: Any) {
        closeHint()
    }
    
    func closeHint() {
        containerView.isHidden = true
        
        UIView.animate(withDuration: Constants.Common.animationTime) {
            self.bgView.alpha = 0
        } completion: { _ in
            self.callBack?()
            self.dismiss(animated: true)
        }
    }
}

private extension PopupHintViewScene {
    func internalSetupUI() {
        guard let model else { return }
        
        containerView.roundCorners(radius: Config.cornerRadius)
        topView.roundCorners(corners: [.topLeft, .topRight], radius: Config.cornerRadius)
        
        if let title = model.title {
            titleLabel.text = title
        }
        
        if let attributedTitle = model.attributedTitle {
            titleLabel.attributedText = attributedTitle
        }
        
        messageLabel.text = model.message ?? ""
        closeButton.isHidden = !model.isClosable
        messageLabel.sizeToFit()
        
        if model.isClosable {
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapOutside))
            bgView.addGestureRecognizer(tapGR)
            callBack = model.buttonHandler
        }
        showHint()
    }
    
    func showHint() {
        UIView.animate(withDuration: Constants.Common.animationTime) {
            self.bgView.alpha = 0.4
        } completion: { _ in
            self.containerView.isHidden = false
        }
    }
    
    @objc func tapOutside() {
        closeHint()
    }
}
