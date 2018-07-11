//
//  RezeptEingabeController.swift
//  App
//
//  Created by Tobias Gozzi on 12/05/2018.
//

import Foundation


class RezeptEingabeController {
    
    let drop: Droplet
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func getAvailableRecips(_ req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("signup")
    }
    
    
}
