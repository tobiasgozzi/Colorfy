//
//  StringExtension.swift
//  App
//
//  Created by Tobias Gozzi on 02/10/2018.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

