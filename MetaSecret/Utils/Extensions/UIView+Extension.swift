//
//  UIView+Extension.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 10.09.2022.
//

import Foundation
import UIKit

extension UIView {
    func roundCorners(corners: UIRectCorner = [.allCorners], radius: Int = 8) {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: corners,
                                     cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
//        layer.masksToBounds = true
    }
    
    func showShadow(shadowColor: UIColor = AppColors.mainBlack,
                    shadowOffset: CGSize = CGSize(width: 1, height: 1),
                    shadowRadius: CGFloat = 5,
                    shadowOpacity: Float = 0.5,
                    cornerRadius: CGFloat = 16) {

        self.layer.masksToBounds = false
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
    }
}
