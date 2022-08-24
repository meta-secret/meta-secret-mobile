//
//  ClusterDeviceCell.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 24.08.2022.
//

import UIKit

class ClusterDeviceCell: UITableViewCell {
    
    //MARK: - OUTLETS
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    func setupCell(vault: Vault) {
        deviceNameLabel.text = vault.deviceName
    }
    
}
