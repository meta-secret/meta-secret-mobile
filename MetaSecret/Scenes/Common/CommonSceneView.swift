//
//  CommonSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.12.2022.
//

import Foundation
import UIKit
import PromiseKit

class CommonSceneView: UIViewController {
    
    let alertManager: Alertable
    var isKeyboardHidden: Bool = true
    
    var commonViewModel: CommonViewModel {
        return CommonViewModel()
    }
    
    init(alertManager: Alertable) {
        self.alertManager = alertManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        refreshData()
    }
    
    func loadData() {
        guard !commonViewModel.isLoadingData else { return }
        alertManager.showLoader()
        commonViewModel.isLoadingData = true
        firstly {
            commonViewModel.loadData()
        }.catch { e in
            self.didFailLoadingData()
        }.finally {
            self.didFinishLoadingData()
        }
    }
    
    func setupUI() {
        setAttributedTitle(commonViewModel.title)
        clearBackButtonTitle()
        setupNotifications()
    }
    
    func updateUI() {}
    
    @objc func refreshData() {
        loadData()
    }
    @objc func keyboardWillShow() {}
    @objc func keyboardWillHide() {}
    
    @objc func keyboardDidShow() {
        isKeyboardHidden = false
    }
    
    @objc func keyboardDidHide() {
        isKeyboardHidden = true
    }
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
    }
        
    func didFinishLoadingData(reload: Bool = true) {
        alertManager.hideLoader()
        updateUI()
    }
    
    func didFailLoadingData(message: Error? = MetaSecretErrorType.commonError) {
        alertManager.hideLoader()
        let text = (message as? MetaSecretErrorType)?.message() ?? message?.localizedDescription
        alertManager.showCommonError(text)
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
