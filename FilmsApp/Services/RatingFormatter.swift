//
//  RatingFormatter.swift
//  FilmsApp
//
//  Created by Boris Kotov on 31.10.2023.
//

import Foundation

class RatingFormatter {
    static let formatter = {
        var f = NumberFormatter()
        f.maximumFractionDigits = 1
        f.minimumFractionDigits = 1
        return f
    }()
}
