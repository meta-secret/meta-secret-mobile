//
//  UIFont+Extension.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 11.09.2022.
//

import Foundation
import UIKit

extension UIFont {
    static func avenirLight(size: CGFloat = 14) -> UIFont {
        return UIFont(name: "AvenirNext-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }
    
    static func avenirRegular(size: CGFloat = 14) -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func avenirMedium(size: CGFloat = 14) -> UIFont {
        return UIFont(name: "AvenirNext-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func avenirHeavy(size: CGFloat = 14) -> UIFont {
        return UIFont(name: "AvenirNext-Heavy", size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
    }
    
    static func avenirBold(size: CGFloat = 14) -> UIFont {
        return UIFont(name: "AvenirNext-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
}
