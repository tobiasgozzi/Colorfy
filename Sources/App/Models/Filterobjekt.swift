//
//  Filterobjekt.swift
//  App
//
//  Created by Tobias Gozzi on 14/05/2018.
//

import Foundation

class Filterobjekt {
    
    
    var connections: [String: WebSocket]
    
    func send(name: String, message: String) {
        let message = message
        
        let messageNode: [String: NodeRepresentable] = [
            "username": name,
            "message": message
        ]
        
        guard let json = try? JSON(node: messageNode) else {
            return
        }
        
        for (username, socket) in connections {
            guard username != name else {
                continue
            }
            
            try? socket.send(json)
        }
    }
    
    
    
    init(farbtonCollection : String, farbton : String, produkt : String, rezepttyp: String, kunde: String) {
        
        self.farbtonCollection = farbtonCollection
        self.farbton = farbton
        self.produkt = rezepttyp
        self.rezepttyp = rezepttyp
        self.kunde = kunde
        connections = [:]

    }
    
    private var farbtonCollection : String
    private var farbton : String
    private var produkt : String
    private var rezepttyp : String
    private var kunde : String
    
    
    func getFarbtonCollection() -> String {
        return farbtonCollection
    }
    
    func getFarbton() -> String {
        return farbton
    }
    
    func getProdukt() -> String {
        return produkt
    }
    
    func getRezepttyp() -> String {
        return rezepttyp
    }
    func getKunde() -> String {
        return kunde
    }
}
