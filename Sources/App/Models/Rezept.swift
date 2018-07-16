import Foundation
import Vapor
import FluentProvider

class Rezept: Model {

    var id: Identifier?
    var rezeptID : String
    var farbnummer : String
    var farbton : String
//    var eKPreis : Float
//    var vKPreis : Float
    var produkt : String
    var anteile : [Rohstoffanteil]
    //var typ : Rezepttyp
    var kunde: String
//    var aufbau : String
//    var notiz :String
    
    init(produkt : String, farbnummer : String, farbton : String, anteil : [Rohstoffanteil],/* typ: Rezepttyp,*/ kunde: String, collection: String ) {
        
        let id = collection + produkt.replacingOccurrences(of: " ", with: "_") + farbnummer.replacingOccurrences(of: " ", with: "_")

        self.id = Identifier.string(id)
        self.rezeptID = id
        self.farbnummer = farbnummer
        self.farbton = farbton
        

        var kostenKalk: Float = 0.0
        var preisKalk: Float = 0.0

        for item in anteil {
            kostenKalk += item.kosten
            preisKalk += item.vkPreis
        }
//        eKPreis = kostenKalk
//        vKPreis = preisKalk
        
        self.produkt = produkt
        self.anteile = anteil
//        self.typ = typ
        self.kunde = kunde
    }
    
    public var setRohstoffanteile : [Rohstoffanteil] {
        set {
            anteile = newValue
        }
        get {
            return anteile
        }
    }
    
    var getCost : Float {
        var kostenKalk: Float = 0.0
        
        for item in anteile {
            kostenKalk += item.kosten
        }
        
        return kostenKalk
    }
    
    var getPrice : Float {
        var preisKalk: Float = 0.0
        
        for item in anteile {
            preisKalk += item.vkPreis
        }
        return preisKalk
    }

    
    
    
    var storage: Storage = Storage()
 
    required init(row: Row) throws {
        self.rezeptID = try row.get("rezeptID")
        self.farbnummer = try row.get("farbnummer")
        self.farbton = try row.get("farbton")
//        self.eKPreis = try row.get("eKPreis")
//        self.vKPreis = try row.get("vKPreis")
        self.produkt = try row.get("produkt")
        self.anteile = try row.get("anteil")
//        self.typ = try row.get("typ")
        self.kunde = try row.get("kunde")

    }
    
    
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("rezeptID", rezeptID)
        try row.set("farbnummer", farbnummer)
        try row.set("farbton", farbton)
//        try row.set("eKPreis", eKPreis)
//        try row.set("vKPreis", vKPreis)
        try row.set("produkt", produkt)
//        try row.set("typ", typ)
        try row.set("anteil", anteile)
        try row.set("kunde", kunde)

        return row
    }
    
}


extension Rezept: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("rezeptID")
            builder.string("farbnummer")
            builder.string("farbton")
//            builder.double("eKPreis")
//            builder.double("vKPreis")
            
            builder.string("kunde")
            builder.string("produkt")
            builder.custom("anteil", type: "[Rohstoffanteil]")
//            builder.custom("typ", type: "Rezepttyp")

        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


// MARK: Node
extension Rezept: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("rezeptID", rezeptID)
        try node.set("farbnummer", farbnummer)
        try node.set("farbton", farbton)
        try node.set("getCost", getCost)
        try node.set("getPrice", getPrice)
        try node.set("produkt", produkt)
        try node.set("kunde", kunde)
//        try node.set("typ", typ)
        try node.set("anteile", anteile)
        
        return node
    }
}


extension Rezept {
    var rohstoffanteile: Children<Rezept, Rohstoffanteil> {
        return children()
    }
}
