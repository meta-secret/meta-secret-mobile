//
//  DeviceInfoSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 30.08.2022.
//

import UIKit

class DeviceInfoSceneView: UIViewController, DeviceInfoProtocol, DataSendable {

    //MARK: - OITLETS
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceNameContainer: UIView!
    
    //MARK: - PROPERTIES
    private var viewModel: DeviceInfoSceneViewModel? = nil
    var dataSent: Any? = nil
    
    //MARK: - LIFE CICLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = DeviceInfoSceneViewModel(delegate: self)
        setupUI()
    }


    //MARK: - ACTIONS
    @IBAction func acceptPressed(_ sender: Any) {
        guard let vault = dataSent as? Vault else { return }
        viewModel?.acceptUser(candidate: vault)
    }
    
    @IBAction func declinePressed(_ sender: Any) {
        guard let vault = dataSent as? Vault else { return }
        viewModel?.declineUser(candidate: vault)
    }
    
    //MARK: - DELEGATION
    func successFullConnection() {
        self.navigationController?.popViewController(animated: true)
    }
}

private extension DeviceInfoSceneView {
    func setupUI() {
        guard let vault = dataSent as? Vault else { return }
        deviceNameLabel.text = vault.vaultName
    }
}
