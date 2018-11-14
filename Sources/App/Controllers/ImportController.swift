//
//  Rezeptsuche.swift
//  App
//
//  Created by Tobias Gozzi on 14/05/2018.
//

import Foundation
import Vapor

class ImportController {
    
    
    let drop: Droplet
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func loadPage(_ req: Request) throws -> ResponseRepresentable {
        let user: Benutzer = try req.auth.assertAuthenticated()

        return try drop.view.make("import-page", ["benutzer" : user])
    }

    
    func elaborateLoadedFile(_ req: Request) throws -> ResponseRepresentable {
        let prodArray = try Produkt.all()

        
        let collectionName = req.formData?["recipeCollectionName"]?.string
        print("\(req.formData?["myFile"]?.filename) importing into \(collectionName)")
        if let dataBytes = req.formData?["myFile"]?.bytes {
            
            
            let data = Data.init(bytes: dataBytes)

            
            let xmlDoc = try XMLDocument.init(data: data, options: XMLNode.Options.documentTidyXML)
            
            if let root = xmlDoc.rootElement() {
                if let rootChildren = root.children {
                    
                    singleProd: for recordNodes in rootChildren {
                        
                        
                        if let leafes = recordNodes.children {
                            
                            //print("\(leafes.count) is count of leafes")
                            var parts : Dictionary<String, Float> = [:]
                            var tempFartonCodice = ""
                            var tempProdukt = ""
                            var mainProduct = ""

                            
                            for (leafindex, leaf) in leafes.enumerated() {
                                        if let name = leaf.name, let val = leaf.stringValue {
//                                            print("\(leafindex) is current index with value \(name) and \(val)")
                                            switch name {
                                            case "codiceTinta":
                                                tempFartonCodice = val
                                                //print("codice tinta \(val)")
                                                break;
                                            case "codiceProdotto":

                                                let nextSibling : Float = (leafes[leafindex + 1].child(at: 0)?.stringValue!.float!)!
                                                //print("codice prodotto \(val)")
                                                mainProduct = val
                                                parts[mainProduct] = nextSibling
                                                break;
                                            case "p1","p2","p3","p4","p5","p6","p7","p8","p9","p10":
//                                                print("P \(name) \(val)")
                                                if val == "" || val == " " {
                                                    break;
                                                }
                                                if (leafes.count > (leafindex + 1) ) {
                                                    
                                                    if let nextSibling = (leafes[leafindex + 1].child(at: 0)?.stringValue) {
                                                        if let floatVal = nextSibling.float {
                                                            tempProdukt = val
                                                            parts[tempProdukt] = floatVal
                                                        }
                                                    }
                                                }
//                                                if let nextSibling = (leafes[leafindex + 1].child(at: 0)?.stringValue) {
//                                                    if let floatVal = nextSibling.float {
//                                                        print("level1")
//                                                        if parts[tempProdukt] != nil {
//                                                            print("level2")
//                                                            tempProdukt = val
//                                                            print("level3")
//                                                            parts[tempProdukt] = floatVal
//                                                            print("level4")
//                                                        }
//                                                    }
//                                                }

                                                break;
                                            default:
                                                break;
                                            }
                                        }
                            }
                            
                            
                            var rohstoffanteile : Dictionary<Produkt, Float> = [:]
                            
                            for part in parts {
                                
                                if prodArray.contains(Produkt(produktID: part.key.trim(), name: "")) {
                                    
                                    let matchingProdArray = prodArray.filter { (prod) -> Bool in
                                        return prod == (Produkt(produktID: part.key.trim(), name: ""))
                                    }
                                    
//                                if let querriedProd = try Produkt.find(part.key.trim()) {
                                    if (matchingProdArray.count > 0) {
                                        rohstoffanteile[matchingProdArray[0]] = part.value
                                    }
//                                    print("\(part.key) found")
                                } else {
                                    print("\(part.key) not found in products")
                                    continue singleProd
                                }
                            }
                            
                            
                            let rezept = Rezept(produkt: mainProduct, farbnummer: tempFartonCodice, farbton: "", anteil: [], kunde: "", collection: collectionName!, note: "")
                            print("\(rezept.farbnummer) \(rezept.kollektion) \(rezept.produkt) instanciated")
                            //check if recipe already exists
                            if let existingRecipe = try Rezept.makeQuery().find(rezept.id) {
                                print("\(existingRecipe.id?.wrapped.string!) already in database")
                                continue singleProd
                            }
                            
                            var teile : [Rohstoffanteil] = []

                            for i in rohstoffanteile {
                                let anteil = Rohstoffanteil(prod: i.key, parts: i.value, id: rezept.id!)
                                do {
//                                    if let existingPart = try Rohstoffanteil.makeQuery().find(anteil.getRohstoffRezeptID.wrapped.string!) {
//                                        print("\(existingPart.id?.wrapped.string!) part already in database")
//                                    } else {
                                        try anteil.save()
                                        teile.append(anteil)
//                                    }
                                } catch let error as NodeError {
                                    print("\(error.debugDescription) \(error.printable) prevented to save rohstoffanteil")
                                }
                                
                                
                            }
                            rezept.setRohstoffanteile = teile
                        
                            do {
//                                if let existingRecipe = try Rezept.makeQuery().find(rezept.id) {
//                                    print("\(existingRecipe.id?.wrapped) already in database")
//                                } else {
                                    try rezept.save()
//                                }
                                
                            } catch let err as NodeError {
                                print("\(err.debugDescription) \(err.printable) prevented to save recipe")
                            }
                        }
                    }
                }
            }
        }

        do {
            print( try Rezept.count())
            print( try Produkt.count())
            print( try Benutzer.count())
            print( try Rohstoffanteil.count())

        } catch let error {
            print(error.localizedDescription)
        }
        
        var anzahl: Int = 0
        do {
            anzahl = try Rezept.count()
        } catch let error {
            print(error.localizedDescription)
        }
        
        let currentUser = req.auth.authenticated(Benutzer.self)
        
        return try drop.view.make("import-page", ["rezeptanzahl": "\(anzahl) ricette salvate", "user": currentUser?.benutzerechte, "benutzer" : currentUser])
        
    }
    
    func deleteProducts(_ req: Request) throws -> ResponseRepresentable {

        try Produkt.revert(Produkt.database!)
        
        let storedProducts = try Produkt.all().count
        let user: Benutzer = try req.auth.assertAuthenticated()

        
        return try drop.view.make("import-page", ["Produktanzahl" : storedProducts, "benutzer" : user])
        
    }
    
    func eraseDatabase(_ req: Request) throws -> ResponseRepresentable {

        do {
            
            try Rezept.revert(Rezept.database!)
            try Rohstoffanteil.revert(Rohstoffanteil.database!)
            try print(Rezept.count())
        } catch let error {
            print(error.localizedDescription)
        }
        
        var anzahl: Int = 0
        do {
            anzahl = try Rezept.count()
        } catch let error {
            print(error.localizedDescription)
        }

        let user: Benutzer = try req.auth.assertAuthenticated()

            
        return try drop.view.make("import-page", ["rezeptanzahl": "\(anzahl) ricette salvate", "benutzer" : user ])

    }
    //*
    //*used to save
    func saveXML(doc: Data) {
        
        let fileManager : FileManager = FileManager.default
        
        let path = "/root/imports/import\(Date.init().description).xml"
        
        fileManager.createFile(atPath: path, contents: doc, attributes: nil)
    }
    
    func importProductsFromJson(_ req:Request) throws -> ResponseRepresentable {

        if let jsonBytes = req.formData?["myProducts"]?.bytes {

            let decoder = JSONDecoder()
            
            let data = Data.init(bytes: jsonBytes)
            
            let products = try decoder.decode(Array<Produkt>.self, from: data)
            for product in products {
                try product.save()
            }

        }

        let productsarray = try Produkt.makeQuery().all()
        
        for item in productsarray {
            print("\(item.codex) \(item.name) \(item.id) \(item.kosten) \(item.preis)")
        }
        
        let storedProducts = try Produkt.all().count
        let user: Benutzer = try req.auth.assertAuthenticated()

        return try drop.view.make("import-page",["Produktanzahl" : storedProducts, "benutzer" : user])
    }
    

    
}

