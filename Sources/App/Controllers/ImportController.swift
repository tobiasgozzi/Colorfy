//
//  Rezeptsuche.swift
//  App
//
//  Created by Tobias Gozzi on 14/05/2018.
//

import Foundation
import Vapor

let products : Dictionary<String, Dictionary<String, String>> = [
    "H36025W" : [
        "name" : "PUR Color Weiss",
        "price" : "7.31",
        "cost" : "3.69"
    ],
    "H95025W" : [
        "name" : "PUR Color Converter",
        "price" : "7.21",
        "cost" : "3.86"
    ],
    "I790W" : [
        "name" : "PUR Hochglanz Weiss",
        "price" : "8.10",
        "cost" : "4.34"
    ],
    "I360W" : [
        "name" : "PUR Hochglanz Converter",
        "price" : "8.10",
        "cost" : "4.27"
    ],
    "M56020W" : [
        "name" : "Kompakt Colour Weiss",
        "price" : "10.44",
        "cost" : "5.60"
    ],
    "M55020W" : [
        "name" : "Kompakt Colour Converter",
        "price" : "10.44",
        "cost" : "5.60"
    ],
    "82555 Arancio Sc" : [
        "name" : "82555 Arancio scuro",
        "price" : "88.27",
        "cost" : "47.26"
    ],
    "82508 Rosso Sc." : [
        "name" : "82508 Rosso scuro",
        "price" : "31.33",
        "cost" : "16.78"
    ],
    "82536 Verde" : [
        "name" : "82536 Verde",
        "price" : "32.84",
        "cost" : "17.58"
    ],
    "82551 Giallo Ch." : [
        "name" : "82551 Giallo chiaro",
        "price" : "68.02",
        "cost" : "36.43"
    ],
    "82063 Arancio Ch" : [
        "name" : "82063 Arancio Chiaro",
        "price" : "62.69",
        "cost" : "33.57"
    ],
    "82504 Blu Verde" : [
        "name" : "82504 Blu Verde",
        "price" : "33.91",
        "cost" : "18.16"
    ],
    "82556 Blu Rosso" : [
        "name" : "82556 Blu Rosso",
        "price" : "31.77",
        "cost" : "17.02"
    ],
    "82507 Giallo Os." : [
        "name" : "82507 Giallo ossido",
        "price" : "19.61",
        "cost" : "10.51"
    ],
    "82010 Giallo" : [
        "name" : "AC 010 Giallo",
        "price" : "64.17",
        "cost" : "34.36"
    ],
    "82545 Violetto" : [
        "name" : "82545 Violetto",
        "price" : "75.48",
        "cost" : "40.42"
    ],
    "82590 Magenta" : [
        "name" : "82590 Magenta",
        "price" : "68.02",
        "cost" : "36.43"
    ],
    "82541 Viola" : [
        "name" : "82541 Viola",
        "price" : "69.07",
        "cost" : "36.99"
    ],
    "82597 Nero" : [
        "name" : "82597 Nero",
        "price" : "22.17",
        "cost" : "11.87"
    ],
    "82512 Rosso Os." : [
        "name" : "82512 Rosso ossido",
        "price" : "21.12",
        "cost" : "11.30"
    ],
    "82557 Rosso V." : [
        "name" : "82557 Rosso vivo",
        "price" : "69.07",
        "cost" : "36.99"
    ],
    "82600 Bianco" : [
        "name" : "82600 Bianco",
        "price" : "10.88",
        "cost" : "5.83"
    ],
    "PU9551 Giallo At." : [
        "name" : "82551 Giallo chiaro",
        "price" : "68.02",
        "cost" : "36.43"
    ],
    "82263 Giallo L." : [
        "name" : "82263 Giallo limone",
        "price" : "79.10",
        "cost" : "42.35"
    ],
    "82515 Giallo C." : [
        "name" : "82515 Giallo caldo",
        "price" : "47.75",
        "cost" : "25.57"
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
        
        let collectionName = req.formData?["recipeCollectionName"]?.string
        print("\(req.formData?["myFile"]?.filename) importing into \(collectionName)")
        if let dataBytes = req.formData?["myFile"]?.bytes {
            
            
            let data = Data.init(bytes: dataBytes)

            
            let xmlDoc = try XMLDocument.init(data: data, options: XMLNode.Options.documentTidyXML)
            
            if let root = xmlDoc.rootElement() {
                if let rootChildren = root.children {
                    
                    for recordNodes in rootChildren {
                        
                        
                        if let leafes = recordNodes.children {
                            
                            //print("\(leafes.count) is count of leafes")
                            var parts : Dictionary<String, Float> = [:]
                            var tempFartonCodice = ""
                            var tempProdukt = ""
                            var mainProduct = ""

                            
                            for (leafindex, leaf) in leafes.enumerated() {

//                                if let leafChildren = leaf.children {
                                
//                                    for leafValue in leafChildren {

                                        if let name = leaf.name, let val = leaf.stringValue {
                                            //print("\(leafindex) is current index with value \(name) and \(val)")
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
                                            case "p1","p2","p3","p4","p5","p6":
                                                //print("P \(name) \(val)")
                                                if val == "" || val == " " {
                                                    break;
                                                }
                                                let nextSibling : Float = (leafes[leafindex + 1].child(at: 0)?.stringValue!.float!)!
                                                //print("--- \(nextSibling)")

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
                            
                            
                            let rezept = Rezept(produkt: mainProduct, farbnummer: tempFartonCodice, farbton: "", anteil: [], kunde: "", collection: collectionName!)
                            
                            
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
        
        let currentUser = req.auth.authenticated(Benutzer.self)
        
        return try drop.view.make("import-page", ["rezeptanzahl": "\(anzahl) ricette salvate", "user": currentUser?.benutzerechte])
        
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
    //*
    //*used to save
    func saveXML(doc: Data) {
        
        let fileManager : FileManager = FileManager.default
        
        let path = "/root/imports/import\(Date.init().description).xml"
        
        fileManager.createFile(atPath: path, contents: doc, attributes: nil)
    }
    

    
}

