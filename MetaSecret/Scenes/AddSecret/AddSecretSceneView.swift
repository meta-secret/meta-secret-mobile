//
//  AddSecretSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import UIKit
import PromiseKit

class AddSecretSceneView: CommonSceneView, AddSecretProtocol {
    //MARK: - OUTLETS
    @IBOutlet weak var splitRestoreButton: UIButton!
    @IBOutlet weak var addPassTitleLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var addDescriptionTitle: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var selectSaveInfoLabel: UILabel!
    @IBOutlet weak var selectSaveButton: UIButton!
    
    //MARK: - PROPERTIES
    private struct Config {
        static let titleSize: CGFloat = 18
    }
    
    var viewModel: AddSecretViewModel
    override var commonViewModel: CommonViewModel {
        return viewModel
    }
    
    private var isLocalySaved: Bool = false
    private var isFulySplited: Bool = false
    
    //MARK: - LIFE CICLE
    init(viewModel: AddSecretViewModel, alertManager: Alertable) {
        self.viewModel = viewModel
        super.init(alertManager: alertManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        innerSetupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(switchCallback(_:)), name: NSNotification.Name(rawValue: "distributionService"), object: nil)
    }
    
    //MARK: - ACTIONS
    @IBAction func splitRestoreButtonPressed(_ sender: Any) {
        hideKeyboard()

        if viewModel.modeType == .readOnly {
            restore()
        } else if viewModel.modeType == .edit {
            split()
        }
    }
    
    @IBAction func selectSaveButtonTapped(_ sender: Any) {
        alertManager.showLoader()
        var isThereError = false
        firstly {
            viewModel.split(secret: passwordTextField.text ?? "", descriptionName: descriptionTextField.text ?? "")
        }.then {
            self.viewModel.encryptAndDistribute()
        }.catch { e in
            self.alertManager.hideLoader()
            let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
            self.alertManager.showCommonError(text)
            self.resetScreen()
            isThereError = true
        }.finally {
            if !isThereError {
                self.alertManager.hideLoader()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: - AddSecretProtocol
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showRestoreResult(password: String?) {
        alertManager.hideLoader()
        alertManager.hideAlert()
        guard let password else {
            alertManager.showCommonError(MetaSecretErrorType.cantRestore.message())
            return
        }
        
        passwordTextField.text = password
        viewModel.stopRestoring()
    }
}

private extension AddSecretSceneView {
    //MARK: - UI SETUP
    func innerSetupUI() {
        super.setupUI()
        setupNavBar()
        
        //TapGR
        let globalTapGR = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(globalTapGR)
        switchMode()
        
        // Texts
        addDescriptionTitle.text = viewModel.descriptionHeaderText
        addPassTitleLabel.text = viewModel.addPasswordHeaderText
        selectSaveInfoLabel.text = Constants.AddSecret.selectDevice
        selectSaveButton.setTitle(Constants.AddSecret.selectDeviceButtonLocal, for: .normal)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setupNavBar() {
        // Back button
        navigationController?.navigationBar.tintColor = AppColors.mainOrange
        navigationItem.hidesBackButton = true
        let chevronLeft = AppImages.chevroneLeft
        let newBackButton = UIBarButtonItem(image: chevronLeft, style: .plain, target: self, action: #selector(backPressed))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    //MARK: - CALL BACK FROM DISTRIBUTION SERVICE
    @objc func switchCallback(_ notification: NSNotification) {
        if let type = notification.userInfo?["type"] as? CallBackType {
            switch type {
            case .Claims(let secret, _):
                self.showRestoreResult(password: secret)
            case .Failure:
                self.showRestoreResult(password: nil)
            default:
                break
            }
        }
    }
    
    //MARK: - MAIN FUNCTIONALITY
    func split() {
        alertManager.showLoader()
        firstly {
            viewModel.split(secret: passwordTextField.text ?? "", descriptionName: descriptionTextField.text ?? "")
        }.catch { e in
            self.alertManager.hideLoader()
            let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
            self.alertManager.showCommonError(text)
            self.resetScreen()
            self.switchMode()
        }.finally {
            self.alertManager.hideLoader()
            self.switchMode()
        }
    }
    
    func restore() {
        viewModel.restore(descriptionName: descriptionTextField.text ?? "")
    }
    
    
    
    //MARK: - CHANGING SCREEN MODE
    func resetScreen() {
        passwordTextField.text = ""
        descriptionTextField.text = ""
    }
    
    func switchMode() {
        switch viewModel.modeType {
        case .readOnly:
            descriptionTextField.isUserInteractionEnabled = false
            descriptionTextField.isEnabled = false
            descriptionTextField.text = viewModel.descriptionText
            
            passwordTextField.isUserInteractionEnabled = false
            passwordTextField.isEnabled = false
            passwordTextField.text = nil
            passwordTextField.placeholder = Constants.AddSecret.password
            
            splitRestoreButton.setTitle(Constants.AddSecret.showSecret, for: .normal)
            splitRestoreButton.isUserInteractionEnabled = true
            splitRestoreButton.backgroundColor = AppColors.mainOrange
            splitRestoreButton.isHidden = false
            
            instructionLabel.isHidden = true
            selectSaveInfoLabel.isHidden = true
            selectSaveButton.isHidden = true
        case .edit:
            descriptionTextField.isUserInteractionEnabled = true
            descriptionTextField.isEnabled = true
            descriptionTextField.placeholder = Constants.AddSecret.description
            descriptionTextField.text = viewModel.descriptionText
            
            passwordTextField.isUserInteractionEnabled = true
            passwordTextField.isEnabled = true
            passwordTextField.placeholder = Constants.AddSecret.password
            
            splitRestoreButton.setTitle(Constants.AddSecret.split, for: .normal)
            splitRestoreButton.isUserInteractionEnabled = false
            splitRestoreButton.backgroundColor = .systemGray5
            splitRestoreButton.isHidden = true
            
            instructionLabel.isHidden = true
            selectSaveInfoLabel.isHidden = true
            selectSaveButton.isHidden = false
            selectSaveButton.isUserInteractionEnabled = false
            selectSaveButton.backgroundColor = .systemGray5
        case .distribute:
            descriptionTextField.isUserInteractionEnabled = false
            descriptionTextField.isEnabled = false
            
            passwordTextField.isUserInteractionEnabled = false
            passwordTextField.isEnabled = false
            
            splitRestoreButton.setTitle(Constants.AddSecret.split, for: .normal)
            splitRestoreButton.isUserInteractionEnabled = false
            splitRestoreButton.backgroundColor = .systemGray5
            splitRestoreButton.isHidden = true
            
            instructionLabel.isHidden = true
            
            selectSaveButton.isHidden = false
            selectSaveButton.isUserInteractionEnabled = false
            selectSaveButton.backgroundColor = .systemGray5
//            if viewModel.vaultsCount() <= Constants.Common.neededMembersCount {
            selectSaveInfoLabel.isHidden = true
            instructionLabel.isHidden = true
            selectSaveButton.setTitle(Constants.AddSecret.selectDeviceButtonLocal, for: .normal)
//            } else {
//                selectSaveInfoLabel.isHidden = false
//                selectSaveButton.setTitle(Constants.AddSecret.selectDeviceButton, for: .normal)
//            }
        }
    }
    
    @objc func hideKeyboard() {
        passwordTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
    }
    
    @objc func backPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TEXT FIELD DELEGATE
    @objc func textFieldDidChange(_ textField: UITextField) {
        instructionLabel.isHidden = true
        if let pass = passwordTextField.text, !pass.isEmpty, let note = descriptionTextField.text, !note.isEmpty {
            selectSaveButton.isUserInteractionEnabled = true
            selectSaveButton.backgroundColor = AppColors.mainOrange
        } else {
            selectSaveButton.isUserInteractionEnabled = false
            selectSaveButton.backgroundColor = .systemGray5
        }
    }
}

enum ModeType {
    case readOnly
    case edit
    case distribute
}
