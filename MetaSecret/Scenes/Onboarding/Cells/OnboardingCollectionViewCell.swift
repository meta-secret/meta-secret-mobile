//
//  OnboardingCollectionViewCell.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 15.09.2022.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var imageAspectRatioConstraint: NSLayoutConstraint?
    
    // MARK: - Functions
    func setup(cellType: OnboardingSceneView.CellType) {
        imageView.image = cellType.image
        titleLabel.text = cellType.title
        descriptionLabel.text = cellType.description
    }
}
