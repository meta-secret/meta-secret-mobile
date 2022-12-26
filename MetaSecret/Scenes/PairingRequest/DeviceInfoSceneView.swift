//
//  DeviceInfoSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 30.08.2022.
//

import UIKit

class DeviceInfoSceneView: UIViewController, DeviceInfoProtocol, DataSendable {

    //MARK: - OITLETS
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var warningMessageLabel: UILabel!
    
    //MARK: - PROPERTIES
    private struct Config {
        static let titleSize: CGFloat = 18
        static let cornerRadius = 16
        static let borderWidth: CGFloat = 2
    }
    
    private var viewModel: DeviceInfoSceneViewModel? = nil
    private var callBack: ((Bool)->())?
    var dataSent: Any? = nil
    
    //MARK: - LIFE CICLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = DeviceInfoSceneViewModel(delegate: self)
        setupUI()
    }


    //MARK: - ACTIONS
    @IBAction func acceptPressed(_ sender: Any) {
        guard let data = dataSent as? SceneSendDataModel, let signature = data.signature else { return }
        viewModel?.acceptUser(candidate: signature)
    }
    
    @IBAction func declinePressed(_ sender: Any) {
        guard let data = dataSent as? SceneSendDataModel, let signature = data.signature else { return }
        viewModel?.declineUser(candidate: signature)
    }
    
    //MARK: - DELEGATION
    func successFullConnection(isAccept: Bool) {
        callBack?(isAccept)
        self.navigationController?.popViewController(animated: true)
    }
}

private extension DeviceInfoSceneView {
    func setupUI() {
        guard let data = dataSent as? SceneSendDataModel, let signature = data.signature else { return }
        
        acceptButton.setTitle(Constants.PairingDeveice.accept, for: .normal)
        declineButton.setTitle(Constants.PairingDeveice.decline, for: .normal)
        warningMessageLabel.text = Constants.PairingDeveice.warningMessage
        callBack = data.callBack
        
        // Title
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirMedium(size: Config.titleSize)]
        
        self.title = Constants.PairingDeveice.title
        
        stackView.showShadow()
        
        // Back button
        navigationController?.navigationBar.tintColor = AppColors.mainOrange
        
        //Buttons
        acceptButton.layer.cornerRadius = CGFloat(Config.cornerRadius)
        acceptButton.clipsToBounds = true
        declineButton.layer.cornerRadius = CGFloat(Config.cornerRadius)
        declineButton.layer.borderColor = AppColors.mainBlack.cgColor
        declineButton.layer.borderWidth = Config.borderWidth
        declineButton.clipsToBounds = true
        buttonsContainer.showShadow()
        
        //Texts
        deviceNameLabel.text = Device().deviceName
        userNameLabel.text = signature.vaultName
        deviceIdLabel.text = Device().deviceId
    }
}
