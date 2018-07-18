//
//  Rezeptsuche.swift
//  App
//
//  Created by Tobias Gozzi on 14/05/2018.
//

import Foundation

class RezeptAusleseController {
    
    
    
    let drop: Droplet
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func showRecipe(_ req: Request) throws -> ResponseRepresentable {
        
        guard let rezeptString = req.parameters["recipe"]?.string else {
            print("parameter recipe not found")
            return try drop.view.make("main")
        }
        guard let rezept = try Rezept.makeQuery().filter("rezeptID", rezeptString).first() else {
            print("recipe not found \(rezeptString)")
            return try drop.view.make("recipe", ["recipe" : "nessun risultato"])
        }
        
        print(rezept.farbnummer)
        print(rezept.anteile.count)

        var indexes : [Int] = []
        for i in 0 ... rezept.anteile.count {
            indexes.append(i)
        }
        
        return try drop.view.make("recipe", ["recipe" : try rezept.makeNode(in: nil), "anteile": rezept.anteile.makeNode(in: nil), "benutzerrechte" : req.auth.authenticated(Benutzer.self)?.benutzerechte, "indexes" : indexes])
        
    }
    
    func updateQuantity(_ req: Request, _ ws: WebSocket) throws {
        
        
        
            ws.onText = { ws, text in
                
                //ws gets [String] with quantityfactor and quantities, needs to calculate and send quantities back
                
                
//                let answer = rezeptsuche.compareRecipeWithSearchphrase(input: text)
                
                print(text + " sent from client")
                try ws.send(text)
            }

        
    }
    

}

