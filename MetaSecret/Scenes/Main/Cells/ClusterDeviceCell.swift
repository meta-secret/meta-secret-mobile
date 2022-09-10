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
    @IBOutlet weak var chevroneImage: UIImageView!
    
    func setupCell(content: CellSetupDate) {
        deviceNameLabel.text = content.title
        statusLabel.text = content.subtitle
        
        chevroneImage.isHidden = !content.boolValue
        
        statusLabel.textColor = content.boolValue ? AppColors.mainOrange : AppColors.mainBlack
    }
    
}
