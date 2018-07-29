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
    
    func showFormPage(_ req: Request) throws -> ResponseRepresentable {
        var productsArray : [Produkt] = try Produkt.makeQuery().all()

        productsArray.sort { (prA, prB) -> Bool in
            return prA.name > prB.name
        }
        
        print(productsArray.count)
        print(productsArray)
        
        let user : Benutzer = try req.auth.assertAuthenticated()

        return try drop.view.make("insert-recipe",["products":productsArray, "benutzer" : user])
    }
    
    func elaborateNewRecipe(_ req :Request) throws -> ResponseRepresentable {
        let products = try Produkt.makeQuery().all()
        var rezeptIDforRedirection = ""
        if let data = req.formData {
            
            guard let colorName = data["tinta"]?.string else {
                return try drop.view.make("insert-recipe")
            }
            
            guard let collection = data["collection"]?.string else {
                return try drop.view.make("insert-recipe")
            }
            
            guard let mainProduct = data["product1"]?.string else {
                return try drop.view.make("insert-recipe")
            }
            guard let cliente = data["cliente"]?.string else {
                return try drop.view.make("insert-recipe")
            }
            guard let colore = data["selezioneColore"]?.string else {
                return try drop.view.make("insert-recipe")
            }

            let rezept = Rezept(produkt: mainProduct , farbnummer: colorName, farbton: colore, anteil: [], kunde: cliente, collection: collection)
            
            rezeptIDforRedirection = rezept.rezeptID
            
            var parts : [Rohstoffanteil] = []
            
            for i in 1..<6 {
                if let productLine = data["product\(i)"]?.string {
                    if let quantityLine = data["quantity\(i)"]?.float {
                        print("\(productLine) \(quantityLine)")
                        
                        let currentProduct = Produkt(produktID: productLine, name: "")
                        
                        let partProduct = products.filter({ (prod) -> Bool in
                            return prod.returnProductID() == productLine
                        })[0]
                        
                        parts.append(Rohstoffanteil(prod: partProduct, parts: quantityLine, id: rezept.id!))
                        
                    }
                }
            }
            
            rezept.anteile = parts
            
            try rezept.save()

            
        }

        
        return Response.init(redirect: "/recipe/\(rezeptIDforRedirection)")
        
    }
    
    
}
