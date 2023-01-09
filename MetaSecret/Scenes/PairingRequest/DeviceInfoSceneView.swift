//
//  DeviceInfoSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 30.08.2022.
//

import UIKit
import PromiseKit

class DeviceInfoSceneView: CommonSceneView, DeviceInfoProtocol {

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
    
    var viewModel: DeviceInfoSceneViewModel
    var data: SceneSendDataModel? = nil
    override var commonViewModel: CommonViewModel {
        return viewModel
    }

    private var callBack: ((Bool)->())?
    
    //MARK: - LIFE CICLE
    init(viewModel: DeviceInfoSceneViewModel, alertManager: Alertable) {
        self.viewModel = viewModel
        super.init(alertManager: alertManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        internalSetupUI()
    }


    //MARK: - ACTIONS
    @IBAction func acceptPressed(_ sender: Any) {
        var isThereError = false
        guard let data, let signature = data.signature else { return }
        alertManager.showLoader()
        firstly {
            viewModel.acceptUser(candidate: signature)
        }.catch { e in
            let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
            self.alertManager.hideLoader()
            self.alertManager.showCommonError(text)
            isThereError = true
        }.finally {
            if !isThereError {
                self.alertManager.hideLoader()
                self.data?.callBack?(true)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func declinePressed(_ sender: Any) {
        var isThereError = false
        guard let data, let signature = data.signature else { return }
        alertManager.showLoader()
        firstly {
            viewModel.declineUser(candidate: signature)
        }.catch { e in
            let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
            self.alertManager.hideLoader()
            self.alertManager.showCommonError(text)
            isThereError = true
        }.finally {
            if !isThereError {
                self.alertManager.hideLoader()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

private extension DeviceInfoSceneView {
    func internalSetupUI() {
        super.setupUI()
        
        guard let data, let signature = data.signature else { return }
        
        acceptButton.setTitle(Constants.PairingDeveice.accept, for: .normal)
        declineButton.setTitle(Constants.PairingDeveice.decline, for: .normal)
        warningMessageLabel.text = Constants.PairingDeveice.warningMessage
        callBack = data.callBack
        
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
