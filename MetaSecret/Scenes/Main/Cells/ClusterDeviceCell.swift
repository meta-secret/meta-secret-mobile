//
//  ClusterDeviceCell.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 24.08.2022.
//

import UIKit

protocol ClusterDeviceCellDelegate: AnyObject {
    func buttonTapped()
    func acceptTapped(_ content: CellSetupDate)
    func declineTapped(_ content: CellSetupDate)
}

class ClusterDeviceCell: UITableViewCell {
    
    //MARK: - OUTLETS
    @IBOutlet weak var deviceIDLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var chevroneImage: UIImageView!
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    //MARK: - PROPERTIES
    private struct Config {
        static let titleSize: CGFloat = 18
        static let cornerRadius = 16
        static let borderWidth: CGFloat = 2
    }
    
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
        
        acceptButton.setTitle(Constants.PairingDeveice.accept, for: .normal)
        declineButton.setTitle(Constants.PairingDeveice.decline, for: .normal)

        acceptButton.layer.cornerRadius = CGFloat(Config.cornerRadius)
        acceptButton.clipsToBounds = true
        declineButton.layer.cornerRadius = CGFloat(Config.cornerRadius)
        declineButton.layer.borderColor = AppColors.mainBlack.cgColor
        declineButton.layer.borderWidth = Config.borderWidth
        declineButton.clipsToBounds = true
        
        buttonsContainer.isHidden = content.status != .Pending
    }
    
    @IBAction func chevronTapped(_ sender: Any) {
        guard let _ = content.imageName else { return }
        delegate?.buttonTapped()
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
        delegate?.acceptTapped(content)
    }
    
    @IBAction func declineTapped(_ sender: Any) {
        delegate?.declineTapped(content)
    }
}
