//
//  ClusterDeviceCell.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 24.08.2022.
//

import UIKit

class ClusterDeviceCell: UITableViewCell {
    
    //MARK: - OUTLETS
    @IBOutlet weak var deviceIDLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var chevroneImage: UIImageView!
    
    func setupCell(content: CellSetupDate) {
        deviceNameLabel.text = content.title
        statusLabel.text = content.subtitle
        deviceIDLabel.text = content.id
        chevroneImage.image = content.imageName ?? AppImages.chevroneRight
        
        chevroneImage.isHidden = !content.boolValue
        statusLabel.textColor = AppColors.mainOrange
    }
    
}
