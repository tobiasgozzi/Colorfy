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
    
    private var _produkt : String
    private var _anteil : Float
    private var _kosten: Float
    private var _vKPreis: Float
    let rezeptID: Identifier

    
    init(prod : Produkt, parts: Float, id : Identifier) {
        
        self._produkt = prod.produktID
        self._anteil = parts
        self._kosten = prod.kosten * parts
        self._vKPreis = prod.preis * parts
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
    public var kosten: Float {
        get {
            return _kosten
        }
    }
    public var vkPreis: Float {
        get {
            return _vKPreis
        }
    }
    
    
    var storage = Storage()

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("produkt", _produkt)
        try row.set("anteil", _anteil)
        try row.set("kosten", _kosten)
        try row.set("vKPreis", _vKPreis)

        return row
    }

    required init(row: Row) throws {
        self._produkt = try row.get("produkt")
        self._anteil = try row.get("anteil")
        self._kosten = try row.get("kosten")
        self._vKPreis = try row.get("vKPreis")
        self.rezeptID = try row.get("rezeptID")
    }

    
}


extension Rohstoffanteil : Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (builder) in
            builder.string("produkt")
            builder.double("anteil")
            builder.double("kosten")
            builder.double("vKPreis")
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
        try node.set("produkt", _produkt)
        try node.set("anteil", _anteil)
        try node.set("kosten", _kosten)
        try node.set("vKPreis", _vKPreis)
        let stringAnteil = String(format: "%.2f", _anteil)
        try node.set("stringAnteil", stringAnteil)
        return node
    }
}

extension Rohstoffanteil {
    
    var owner: Parent<Rohstoffanteil, Rezept> {
        return parent(id: rezeptID)
    }
}

