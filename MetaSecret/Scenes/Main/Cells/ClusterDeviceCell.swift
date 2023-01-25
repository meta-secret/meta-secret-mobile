//
//  ClusterDeviceCell.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 24.08.2022.
//

import UIKit

protocol ClusterDeviceCellDelegate: AnyObject {
    func buttonTapped()
}

class ClusterDeviceCell: UITableViewCell {
    
    //MARK: - OUTLETS
    @IBOutlet weak var deviceIDLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var chevroneImage: UIImageView!
    
    private var content: CellSetupDate!
    weak var delegate: ClusterDeviceCellDelegate? = nil
    
    func setupCell(content: CellSetupDate) {
        self.content = content
        deviceNameLabel.text = content.title
        statusLabel.text = content.subtitle
        deviceIDLabel.text = content.id
        chevroneImage.image = content.imageName ?? AppImages.chevroneRight
        chevroneImage.tintColor = content.imageName == nil ? AppColors.mainBlack : AppColors.mainOrange
        chevroneImage.isHidden = !content.boolValue
        chevronButton.isHidden = !content.boolValue
        chevronButton.setTitle("", for: .normal)
        statusLabel.textColor = AppColors.mainOrange
    }
    
    @IBAction func chevronTapped(_ sender: Any) {
        guard let _ = content.imageName else { return }
        delegate?.buttonTapped()
    }
}
