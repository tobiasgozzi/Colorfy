//
//  Rohstoffanteil.swift
//  App
//
//  Created by Tobias Gozzi on 07/05/2018.
//

import Foundation
import Vapor
import FluentProvider


class Rohstoffanteil : Model {
    
    //internal var id : Identifier?
    private var _produkt : String
    private var _produktID : String
    private var _anteil : Float
//    private var _grundpreisEK: Float
//    private var _grundpreisVK: Float
    let rezeptID: Identifier

    
    init(prod : Produkt, parts: Float, id : Identifier) {
        
        self._produkt = prod.name
        self._produktID = prod.returnProductID().string
        print("\(prod.returnProductID().string) is returned from product")
        self._anteil = parts
        //self.id = Identifier.string(id.string! + prod.returnProductID().string)
//        self._grundpreisEK = prod.kosten
//        self._grundpreisVK = prod.preis
        self.rezeptID = id
    }

    
    public var produkt: String {
        get {
            return _produkt
        }
    }
    
    public var anteil: Float {
        get {
            return _anteil
        }
    }
    public var produktID: String {
        get {
            return _produktID
        }
    }

    

    public func getKosten() -> Float {
        var produkt : Produkt?
        do {
             produkt = try Produkt.find(produktID)
        } catch {
            
        }
        if let rightProdukt = produkt {
            return rightProdukt.kosten * anteil/1000
        } else {
            return 0
        }
    }
    
    public func getVKPreis() -> Float {
        var produkt : Produkt?
        do {
            produkt = try Produkt.find(produktID)
        } catch {
            
        }
        if let rightProdukt = produkt {
            return rightProdukt.preis * anteil/1000
        } else {
            return 0
        }
    }

    
    var storage = Storage()

    func makeRow() throws -> Row {
        var row = Row()
        //try row.set("id", id)
        try row.set("produkt", _produkt)
        try row.set("anteil", _anteil)
//        try row.set("kosten", _kosten)
//        try row.set("vKPreis", _vKPreis)
        try row.set("produktID", _produktID)
        try row.set("rezeptID", rezeptID)
        return row
    }

    required init(row: Row) throws {
        self._produkt = try row.get("produkt")
        self.rezeptID = try row.get("rezeptID")
        self._anteil = try row.get("anteil")

        self._produktID = try row.get("produktID")
       
        //error lies here
//        let aid : Identifier? = try row.get("id")
//        self.id = aid
//        print(id)

//        self._kosten = try row.get("kosten")
//        self._vKPreis = try row.get("vKPreis")
    }

    
}


extension Rohstoffanteil : Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (builder) in
            //builder.id()
            builder.string("produkt")
            builder.string("produktID")
            builder.double("anteil")
            
            //builder.foreignId(for: Rezept.self)
//            builder.double("kosten")
//            builder.double("vKPreis")
            builder.parent(Rezept.self)
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }

}

extension Rohstoffanteil: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        //try node.set("id", id)

        try node.set("produkt", _produkt)
        try node.set("produktID", _produktID)
        try node.set("anteil", _anteil)
        try node.set("kosten", String(format: "%.2f", getKosten()))

        try node.set("vKPreis", String(format: "%.2f", getVKPreis()))

        let stringAnteil = String(format: "%.2f", _anteil)
        try node.set("stringAnteil", stringAnteil)

        try node.set("rezeptID", rezeptID)
        return node
    }
}

extension Rohstoffanteil {
    
    var owner: Parent<Rohstoffanteil, Rezept> {
        print("\(rezeptID) is parent id")
        return parent(id: rezeptID)
    }
}

