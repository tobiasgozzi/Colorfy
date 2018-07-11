//
//  Produkt.swift
//  App
//
//  Created by Tobias Gozzi on 07/05/2018.
//

import Foundation
import Vapor
import FluentProvider


class Produkt : Model {

    
        
    var storage: Storage = Storage()
    
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("produktID", produktID)
        try row.set("name", name)
        try row.set("variation", variation)
        try row.set("kosten", kosten)
        try row.set("preis", preis)
        return row
    }
    
    required init(row: Row) throws {
        self.produktID = try row.get("produktID")
        self.name = try row.get("name")
        self.variation = try row.get("variation")
        self.kosten = try row.get("kosten")
        self.preis = try row.get("preis")
        
    }
    
    var produktID : String
    var name : String
    var variation: [String]
    //var pfad : String
    var kosten: Float
    var preis: Float
    
    init( produktID : String, name : String, kosten: Float, preis: Float, variation: [String]) {
        self.variation = variation
        self.produktID = produktID
        self.name = name
        //self.pfad = pfad
        self.kosten = kosten
        self.preis = preis
    }
}

extension Produkt : Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { (builder) in
            builder.string("produktID")
            builder.string("name")
            builder.custom("variation", type: "[String]")
            builder.double("kosten")
            builder.double("preis")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}

extension Produkt: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("produktID", produktID)
        try node.set("name", name)
        try node.set("variation", variation)
        try node.set("kosten", kosten)
        try node.set("preis", preis)
        return node
    }
}

extension Produkt : Hashable {
    
    var hashValue: Int {
        return name.hashValue
    }

    static func == (lhs: Produkt, rhs: Produkt) -> Bool {
        return lhs.produktID == rhs.produktID
    }
}

