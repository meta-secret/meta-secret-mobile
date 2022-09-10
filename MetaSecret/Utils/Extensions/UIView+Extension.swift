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
        layer.masksToBounds = true
    }
    
    func dropShadow(color: UIColor = AppColors.mainBlack, fillColor: UIColor = .white, opacity: Float = 0.5, offSet: CGSize = CGSize(width: 1, height: -1), radius: CGFloat = 10, cornerRadius: CGFloat = 16, scale: Bool = true) {
        
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.fillColor = fillColor.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = offSet
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = radius
        layer.insertSublayer(shadowLayer, at: 0)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
