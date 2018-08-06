//
//  Produkt.swift
//  App
//
//  Created by Tobias Gozzi on 07/05/2018.
//

import Foundation
import Vapor
import FluentProvider


class Produkt : Model, Decodable {

    func returnProductID() -> String {
        return id!.wrapped.string!
    }
    
    var storage: Storage = Storage()
    
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("id", id)
        try row.set("name", name)
        try row.set("codex", codex)
        try row.set("kosten", kosten)
        try row.set("preis", preis)
        return row
    }
    
    required init(row: Row) throws {
        self.id = try row.get("id")
        self.name = try row.get("name")
        self.codex = try row.get("codex")
        self.kosten = try row.get("kosten")
        self.preis = try row.get("preis")        
    }
    

    enum CodingKeys : String, CodingKey {
        case id = "id"
        case name = "name"
        case codex = "codex"
        case kosten = "cost"
        case preis = "price"
    }
    
    var id: Identifier?
    var name : String
    var codex: String
    //var pfad : String
    var kosten: Float
    var preis: Float
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let codex = try container.decode(String.self, forKey: .codex)
        let kosten = try container.decode(Float.self, forKey: .kosten)
        let preis = try container.decode(Float.self, forKey: .preis)
        self.init(produktID: id, name: name, kosten: kosten, preis: preis, codex: codex)
    }
    
    init( produktID : String, name : String, kosten: Float, preis: Float, codex: String) {
        self.codex = codex
        self.id = Identifier.string(produktID)
        self.name = name
        //self.pfad = pfad
        self.kosten = kosten
        self.preis = preis
    }
    
    convenience init(produktID : String, name : String) {
        self.init(produktID: produktID, name: name, kosten: 0, preis: 0, codex: "")
    }
    
}

extension Produkt : Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { (builder) in
            builder.id()
            builder.string("name")
            builder.string("codex")
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
        try node.set("id", id)
        try node.set("name", name)
        try node.set("codex", codex)
        try node.set("kosten", kosten)
        try node.set("preis", preis)
        return node
    }
}



extension Produkt : Hashable, Equatable {
    
    var hashValue: Int {
        return name.hashValue
    }

    static func == (lhs: Produkt, rhs: Produkt) -> Bool {
        return lhs.id!.string!  == rhs.id!.string!
    }
}


