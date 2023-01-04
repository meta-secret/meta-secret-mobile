//
//  OnboardingCollectionViewCell.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 15.09.2022.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var imageAspectRatioConstraint: NSLayoutConstraint?
    
    // MARK: - Functions
    func setup(cellType: OnboardingSceneViewModel.CellType) {
        titleLabel.text = cellType.title
        descriptionLabel.text = cellType.description
    }
}
