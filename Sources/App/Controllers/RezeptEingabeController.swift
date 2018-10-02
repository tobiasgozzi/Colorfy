//
//  RezeptEingabeController.swift
//  App
//
//  Created by Tobias Gozzi on 12/05/2018.
//

import Foundation
import HTTP
import Vapor


class RezeptEingabeController {
    
    let drop: Droplet
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func showFormPage(_ req: Request) throws -> ResponseRepresentable {
        var productsArray : [Produkt] = try Produkt.makeQuery().all()
        
        var rezept: Rezept?
        
        do {
            guard let recipeParam = req.formURLEncoded?["rezeptID"] else {
                throw ParserError.invalidMessage
            }
            
            print("\(recipeParam.wrapped)")

            guard let foundProduct = try Rezept.makeQuery().find(recipeParam.wrapped) else {
                print("could not find the recipe")
                throw ParserError.invalidMessage
            }
            
            rezept = foundProduct
            
        } catch let error {
            error.localizedDescription
        }
        
        productsArray.sort { (prA, prB) -> Bool in
            return prA.name > prB.name
        }
        
        print(productsArray.count)
        print(productsArray)
        
        let user : Benutzer = try req.auth.assertAuthenticated()

        
        guard let rezeptPassedAsParam = rezept else {
            print("no product passed as param to modify")
            return try drop.view.make("insert-recipe",["products":productsArray, "benutzer" : user])
        }
        
        var indexes : [Int] = []
        
        for ind in 0 ..< rezeptPassedAsParam.anteile.count {
            indexes.append(ind)
        }
        
        var complementoryIndexes : [Int] = []
        if (indexes.count < 6) {
            for i : Int in indexes.count..<6 {
                complementoryIndexes.append(i+1)
            }
        }
        
        let sortedAnteile = rezeptPassedAsParam.anteile.sorted { (rl, rr) -> Bool in
            return rl.produkt > rr.produkt
        }
        
        return try drop.view.make("insert-recipe",["products":productsArray, "benutzer" : user, "modifyProduct" : rezeptPassedAsParam, "updateMode" : true, "modifyParts" : sortedAnteile, "partIndex" : indexes, "complementaryEmptyParts" : complementoryIndexes])
    }
    
    func elaborateNewRecipe(_ req :Request) throws -> ResponseRepresentable {
        let products = try Produkt.makeQuery().all()
        var rezeptIDforRedirection = ""
        if let data = req.formData {
            
            guard let colorName = data["tinta"]?.string else {
                print("no tinta found")
                return try drop.view.make("insert-recipe")
            }
            
            //replace special characters
            var newColorName = colorName
            for i in "[/<>\\+°^?=()&]" {
                newColorName = newColorName.replacingOccurrences(of: "\(i)", with: "-")
            }
            
            print("\(newColorName) sent from client")
            
            guard let collection = data["collection"]?.string else {
                print("no collection found")
                return try drop.get("insert-recipe")
            }
            
            guard let mainProduct = data["product1"]?.string else {
                print("no product 1 found")
                return try drop.view.make("insert-recipe")
            }
            let cliente = (data["cliente"]?.string != nil) ? data["cliente"]!.string!.capitalizingFirstLetter() : ""
            
            let colore = (data["selezioneColore"]?.string != nil) ? data["selezioneColore"]!.string! : ""

            let notiz = (data["notiz"]?.string != nil) ? data["notiz"]!.string! : ""
            
            let rezept = Rezept(produkt: mainProduct , farbnummer: newColorName, farbton: colore, anteil: [], kunde: cliente, collection: collection, note: notiz)
            
            rezeptIDforRedirection = rezept.rezeptID
            
            var parts : [Rohstoffanteil] = []
            
            for i in 1..<6 {
                if let productLine = data["product\(i)"]?.string {
                    if let quantityLine = data["quantity\(i)"]?.string {
                        
                        let preparedQuantity =  quantityLine.replacingOccurrences(of: ",", with: ".")
                        
                        if let parsedQuantity = preparedQuantity.float {
                            print("\(productLine) \(parsedQuantity) found")
                            
                            let currentProduct = Produkt(produktID: productLine, name: "")
                            
                            let partProduct = products.filter({ (prod) -> Bool in
                                return prod.returnProductID() == productLine
                            })[0]
                            
                            parts.append(Rohstoffanteil(prod: partProduct, parts: parsedQuantity, id: rezept.id!))
                        }
                    }
                }
            }
            
            rezept.anteile = parts
            
            
            //deletes old recipe if data has been modified
            if let oldRecipe = try Rezept.makeQuery().find(rezept.rezeptID) {
                for oldPart in oldRecipe.anteile {
                    let connected = try Rohstoffanteil.makeQuery().find(oldPart.id)
                    try connected?.delete()
                    
                    print("old part deleted")
                }
                oldRecipe.anteile.removeAll()
                try oldRecipe.delete()
                print("old recipe deleted")
            }
            
            try rezept.save()

            
        }

        
        return Response.init(redirect: "/recipe/\(rezeptIDforRedirection)")
        
    }
    
    
}
