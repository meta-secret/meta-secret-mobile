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
    @IBOutlet weak var passwordTextView: UITextView!
    
    @IBOutlet weak var addDescriptionTitle: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!

    @IBOutlet weak var selectSaveButton: UIButton!
    @IBOutlet weak var copiedLabel: UILabel!
    
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
    private let analytic: AnalyticManagerProtocol
    
    //MARK: - LIFE CICLE
    init(viewModel: AddSecretViewModel, alertManager: Alertable, analytic: AnalyticManagerProtocol) {
        self.viewModel = viewModel
        self.analytic = analytic
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
        analytic.event(name: AnalyticsEvent.AddSecretShow)
        
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
        
        analytic.event(name: AnalyticsEvent.SplitSecret)
        
        firstly {
            viewModel.split(secret: passwordTextView.text ?? "", descriptionName: descriptionTextField.text ?? "")
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
        
        passwordTextView.text = password
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
        selectSaveButton.setTitle(Constants.AddSecret.selectDeviceButtonLocal, for: .normal)
        passwordTextView.delegate = self
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        passwordTextView.isScrollEnabled = false
        passwordTextView.layer.cornerRadius = 8.0
        passwordTextView.layer.borderColor = AppColors.mainDarkGray.cgColor
        passwordTextView.layer.borderWidth = 0.5
        passwordTextView.textContainerInset = UIEdgeInsets(top: 12.0, left: 4.0, bottom: 12.0, right: 4.0)
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
            viewModel.split(secret: passwordTextView.text ?? "", descriptionName: descriptionTextField.text ?? "")
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
        analytic.event(name: AnalyticsEvent.RestoreSecret)
        viewModel.restore(descriptionName: descriptionTextField.text ?? "")
    }
    
    
    
    //MARK: - CHANGING SCREEN MODE
    func resetScreen() {
        passwordTextView.text = ""
        descriptionTextField.text = ""
    }
    
    func switchMode() {
        switch viewModel.modeType {
        case .readOnly:
            descriptionTextField.isUserInteractionEnabled = false
            descriptionTextField.isEnabled = false
            descriptionTextField.text = viewModel.descriptionText
            
            passwordTextView.isUserInteractionEnabled = true
            passwordTextView.isEditable = false
            passwordTextView.text = nil
            
            splitRestoreButton.setTitle(Constants.AddSecret.showSecret, for: .normal)
            splitRestoreButton.isUserInteractionEnabled = true
            splitRestoreButton.backgroundColor = AppColors.mainOrange
            splitRestoreButton.isHidden = false
            
            selectSaveButton.isHidden = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(copyText))
            passwordTextView.addGestureRecognizer(tapGesture)
            
        case .edit:
            descriptionTextField.isUserInteractionEnabled = true
            descriptionTextField.isEnabled = true
            descriptionTextField.placeholder = Constants.AddSecret.description
            descriptionTextField.text = viewModel.descriptionText
            
            passwordTextView.isUserInteractionEnabled = true
            passwordTextView.isEditable = true
            
            splitRestoreButton.setTitle(Constants.AddSecret.split, for: .normal)
            splitRestoreButton.isUserInteractionEnabled = false
            splitRestoreButton.backgroundColor = .systemGray5
            splitRestoreButton.isHidden = true
            
            selectSaveButton.isHidden = false
            selectSaveButton.isUserInteractionEnabled = false
            selectSaveButton.backgroundColor = .systemGray5
        case .distribute:
            descriptionTextField.isUserInteractionEnabled = false
            descriptionTextField.isEnabled = false
            
            passwordTextView.isUserInteractionEnabled = true
            passwordTextView.isEditable = false
            
            splitRestoreButton.setTitle(Constants.AddSecret.split, for: .normal)
            splitRestoreButton.isUserInteractionEnabled = false
            splitRestoreButton.backgroundColor = .systemGray5
            splitRestoreButton.isHidden = true
                        
            selectSaveButton.isHidden = false
            selectSaveButton.isUserInteractionEnabled = false
            selectSaveButton.backgroundColor = .systemGray5
            selectSaveButton.setTitle(Constants.AddSecret.selectDeviceButtonLocal, for: .normal)
        }
    }
    
    @objc func copyText() {
        UIPasteboard.general.string = passwordTextView.text
        UIView.animate(withDuration: 0.3, animations: {
            self.copiedLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, animations: {
                self.copiedLabel.alpha = 0.0
            })
        })
    }
    
    @objc func hideKeyboard() {
        passwordTextView.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
    }
    
    @objc func backPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TEXT FIELD DELEGATE
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let pass = passwordTextView.text, !pass.isEmpty, let note = descriptionTextField.text, !note.isEmpty {
            selectSaveButton.isUserInteractionEnabled = true
            selectSaveButton.backgroundColor = AppColors.mainOrange
        } else {
            selectSaveButton.isUserInteractionEnabled = false
            selectSaveButton.backgroundColor = .systemGray5
        }
    }
}

extension AddSecretSceneView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let pass = passwordTextView.text, !pass.isEmpty, let note = descriptionTextField.text, !note.isEmpty {
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
