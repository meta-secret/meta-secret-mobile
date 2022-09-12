//
//  PopupHintViewScene.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 12.09.2022.
//

import UIKit

class PopupHintViewScene: UIViewController, DataSendable {

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
    
    var dataSent: Any?
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - UBACTION
    @IBAction func closeTapped(_ sender: Any) {
        closeHint()
    }
}

private extension PopupHintViewScene {
    func setupUI() {
        containerView.roundCorners(radius: Config.cornerRadius)
        topView.roundCorners(corners: [.topLeft, .topRight], radius: Config.cornerRadius)
        
        guard let model = dataSent as? BottomInfoSheetModel else {
            return
        }
        
        titleLabel.text = model.title
        messageLabel.text = model.message
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapOutside))
        bgView.addGestureRecognizer(tapGR)
        callBack = model.buttonHandler
        showHint()
    }
    
    func showHint() {
        UIView.animate(withDuration: Constants.Common.animationTime) {
            self.bgView.alpha = 0.4
        } completion: { _ in
            self.containerView.isHidden = false
        }
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
    
    @objc func tapOutside() {
        closeHint()
    }
}
