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
    
    //MARK: - PROPERTIES
    private struct Config {
        static let titleSize: CGFloat = 18
        static let cornerRadius = 16
        static let borderWidth: CGFloat = 2
    }
    
    private var viewModel: DeviceInfoSceneViewModel? = nil
    private var callBack: (()->())?
    var dataSent: Any? = nil
    
    //MARK: - LIFE CICLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = DeviceInfoSceneViewModel(delegate: self)
        setupUI()
    }


    //MARK: - ACTIONS
    @IBAction func acceptPressed(_ sender: Any) {
        guard let data = dataSent as? SceneSendDataModel, let vault = data.vault else { return }
        viewModel?.acceptUser(candidate: vault)
    }
    
    @IBAction func declinePressed(_ sender: Any) {
        guard let data = dataSent as? SceneSendDataModel, let vault = data.vault else { return }
        viewModel?.declineUser(candidate: vault)
    }
    
    //MARK: - DELEGATION
    func successFullConnection() {
        callBack?()
        self.navigationController?.popViewController(animated: true)
    }
}

private extension DeviceInfoSceneView {
    func setupUI() {
        guard let data = dataSent as? SceneSendDataModel, let vault = data.vault else { return }
        
        callBack = data.callBack
        
        // Title
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirMedium(size: Config.titleSize)]
        
        self.title = Constants.PairingDeveice.title
        
        stackView.showShadow()
        
        // Back button
        navigationController?.navigationBar.tintColor = AppColors.mainBlack
        
        //Buttons
        acceptButton.layer.cornerRadius = CGFloat(Config.cornerRadius)
        acceptButton.clipsToBounds = true
        declineButton.layer.cornerRadius = CGFloat(Config.cornerRadius)
        declineButton.layer.borderColor = AppColors.mainBlack.cgColor
        declineButton.layer.borderWidth = Config.borderWidth
        declineButton.clipsToBounds = true
        buttonsContainer.showShadow()
        
        //Texts
        deviceNameLabel.text = vault.device?.deviceName ?? ""
        userNameLabel.text = vault.vaultName ?? ""
        deviceIdLabel.text = vault.device?.deviceId ?? ""
        
    }
}
