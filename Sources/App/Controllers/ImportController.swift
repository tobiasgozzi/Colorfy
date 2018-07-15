//
//  Rezeptsuche.swift
//  App
//
//  Created by Tobias Gozzi on 14/05/2018.
//

import Foundation
import Vapor

let products : Dictionary<String, Dictionary<String, String>> = [
    "M56020W" : [
        "name" : "Kompakt Colour trans",
        "price" : "3.43",
        "cost" : "1.32"
    ],
    "M55020W" : [
        "name" : "Kompakt Colour bianco",
        "price" : "3.43",
        "cost" : "1.32"
    ],
    "82555 Arancio Sc" : [
        "name" : "AC 555 Arancio scuro",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82508 Rosso Sc." : [
        "name" : "AC 555 Rosso Sc.",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82536 Verde" : [
        "name" : "AC 555 Verde",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82551 Giallo Ch." : [
        "name" : "AC 555 Giallo Ch.",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82063 Arancio Ch" : [
        "name" : "AC 063 Arancio chiaro",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82504 Blu Verde" : [
        "name" : "AC 504 blu verde",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82556 Blu Rosso" : [
        "name" : "AC 556 blu rosso",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82507 Giallo Os." : [
        "name" : "AC 507 Giallo Ossido",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82010 Giallo" : [
        "name" : "AC 010 Giallo",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82545 Violetto" : [
        "name" : "AC 545 Violetto",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82590 Magenta" : [
        "name" : "AC 590 Magenta",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82541 Viola" : [
        "name" : "AC 555 Arancio scuro",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82597 Nero" : [
        "name" : "AC 555 Arancio scuro",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82512 Rosso Os." : [
        "name" : "AC 555 Arancio scuro",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82557 Rosso V." : [
        "name" : "AC 555 Arancio scuro",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "82600 Bianco" : [
        "name" : "AC 555 Arancio scuro",
        "price" : "14.32",
        "cost" : "8.31"
    ],
    "PU9551 Giallo At." : [
        "name" : "AC 551 Giallo AT",
        "price" : "14.32",
        "cost" : "8.31"
    ]
]

class ImportController {
    
    
    let drop: Droplet
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func loadPage(_ req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("import-page")
    }

    
    func elaborateLoadedFile(_ req: Request) throws -> ResponseRepresentable {
        print((req.data["recipeCollectionName"]?.string)! + " is database name")
        
        
        if let dataBytes = req.formData?["myFile"]?.bytes {
            
            let data = Data.init(bytes: dataBytes)
            _ = saveXML(doc: data)
            let xmlDoc = try XMLDocument.init(data: data, options: XMLNode.Options.documentTidyXML)
            
            

            if let root = xmlDoc.rootElement() {
                if let rootChildren = root.children {
                    
                    for recordNodes in rootChildren {
                        
                        
                        if let leafes = recordNodes.children {
                            
                            print("\(leafes.count) is count of leafes")
                            var parts : Dictionary<String, Float> = [:]
                            var tempFartonCodice = ""
                            var tempProdukt = ""
                            var mainProduct = ""

                            
                            for (leafindex, leaf) in leafes.enumerated() {

//                                if let leafChildren = leaf.children {
                                
//                                    for leafValue in leafChildren {

                                        if let name = leaf.name, let val = leaf.stringValue {
                                            print("\(leafindex) is current index")
                                            switch name {
                                                
                                            case "codiceTinta":
                                                tempFartonCodice = val
                                                print("codice tinta \(val)")
                                                break;
                                            case "codiceProdotto":

                                                let nextSibling : Float = (leafes[leafindex + 1].child(at: 0)?.stringValue!.float!)!
                                                print("codice prodotto \(val)")
                                                mainProduct = val
                                                parts[mainProduct] = nextSibling
                                                break;
                                            case "p1","p2","p3","p4","p5","p6":
                                                print("P \(name) \(val)")
                                                if val == "" || val == " " {
                                                    break;
                                                }
                                                let nextSibling : Float = (leafes[leafindex + 1].child(at: 0)?.stringValue!.float!)!
                                                print("--- \(nextSibling)")

                                                tempProdukt = val
                                                parts[tempProdukt] = nextSibling
                                                break;
                                            default:
                                                
                                                break;
                                            }
                                        }
//                                    }

                                    
//                                }
                                
                            }
                            
                            
                            var rohstoffanteile : Dictionary<Produkt, Float> = [:]
                            
                            
                            for part in parts {
                                
                                
                                if let prodData = products[part.key.trim()] {
                                    
                                    let name = prodData["name"]!
                                    let id = part.key
                                    
                                    let prod = Produkt(produktID: id, name: name, kosten: prodData["cost"]!.float!, preis: prodData["price"]!.float!, variation: [""])
                                    
                                    rohstoffanteile[prod] = part.value

                                } else {
                                    print("\(part.key) not found in products")
                                }
                            }
                            
                            
                            let rezept = Rezept(produkt: mainProduct, farbnummer: tempFartonCodice, farbton: "", anteil: [], kunde: "")
                            
                            
                            var teile : [Rohstoffanteil] = []

                            for i in rohstoffanteile {
                                let anteil = Rohstoffanteil(prod: i.key, parts: i.value, id: rezept.id!)
                                do {
                                    try anteil.save()
                                } catch let error as NodeError {
                                    print("\(error.debugDescription) \(error.printable) prevented to save rohstoffanteil")
                                }
                                
                                teile.append(anteil)
                            }
                            
                            rezept.setRohstoffanteile = teile
                        
                        
                            do {
                                try rezept.save()
                            } catch let err as NodeError {
                                print("\(err.debugDescription) \(err.printable) prevented to save recipe")
                            }
                            

//
//
//
//
//
//                            var parts : Dictionary<String, Float> = [:]
//                            var tempFartonCodice = ""
//                            var tempProdukt = ""
//                            var tempProduktCod = ""
//
//                            for tags in secondLvlChld {
//
//                                if let tag = tags.name {
//                                    switch tag {
//                                    case "codiceTinta":
//                                        tempFartonCodice = tags.
//
//                                        break;
//                                    case "codiceProdotto":
//                                        tempProdukt = tags.
//                                        parts[tempProdukt] = tags.nextSibling?.stringValue!.float!.rounded()
//                                        break;
//                                    case "p1","p2","p3","p4","p5","p6":
//                                        tempProdukt = tags.stringValue!
//                                        parts[tempProdukt] = tags.nextSibling?.stringValue!.float!.rounded()
//                                        print("\(parts[tempProdukt]) \(tags.name)")
//                                        break;
//                                    default:
//
//                                        break;
//                                    }
//
//                                }
//
//                            }
//
//
//
//
//
//
                        }
                    }
                }
                
            }
            
            
//            let item = xmlDoc.children?.first?.children?.first?.children?.first
//            for item in xmlDoc.children! {
//                for child in item.children! {
//                    let recipe = Rezept(rezeptID: Date().smtpFormatted, farbnummer: child., farbton: <#T##String#>, eKPreis: <#T##Float#>, vKPreis: <#T##Float#>, produkte: <#T##[Produkt]#>, anteil: <#T##[Rohstoffanteil]#>, typ: <#T##Rezepttyp#>, kunde: <#T##String#>)
//                }
//            }
            
            
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
        
        
        
        return try drop.view.make("import-page", ["rezeptanzahl": "\(anzahl) ricette salvate" ])
        
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

        
            
        return try drop.view.make("import-page", ["rezeptanzahl": "\(anzahl) ricette salvate" ])

    }
    
    func saveXML(doc: Data) -> Bool {
        
        let fileManager : FileManager = FileManager.default
        
        let path = "/root/imports/import\(Date.init().description)"
        
        do {
            try fileManager.createFile(atPath: path, contents: doc, attributes: nil)
        }
        catch let err {
            return false
        }
        return true
    }
    

    
}

