//
//  Date+Extenson.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 21.09.2022.
//

import Foundation

extension Date {
    func logDate(name: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:mm:ss.SSSS"
        print("## process \(name) at \(dateFormatter.string(from: self))")
    }
}
