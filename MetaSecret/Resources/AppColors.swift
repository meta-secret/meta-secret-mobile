//
//  AppColors.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 14.08.2022.
//

import Foundation
import UIKit

struct AppColors {
    static let mainYellow = UIColor(named: "MainYellow") ?? .yellow
    static let mainOrange = UIColor(named: "MainOrange") ?? .orange
    
    static let mainGray = UIColor(named: "MainGray") ?? .gray
    static let secondaryGray = UIColor(named: "SecondaryGray") ?? .gray
    
    static let mainBlack = UIColor(named: "MainBlack") ?? .black
    static let mainBlack40 = UIColor(named: "MainBlack")?.withAlphaComponent(0.4) ?? .black.withAlphaComponent(0.4)
    
}
