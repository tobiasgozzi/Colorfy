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
    var kollektion: String
    var produkt : String
    var anteile : [Rohstoffanteil]
    //var typ : Rezepttyp
    var kunde: String
//    var aufbau : String
//    var notiz :String
    
    init(produkt : String, farbnummer : String, farbton : String, anteil : [Rohstoffanteil],/* typ: Rezepttyp,*/ kunde: String, collection: String ) {
        
        let id = collection + produkt.replacingOccurrences(of: " ", with: "_") + farbnummer.replacingOccurrences(of: " ", with: "_")
        print("### \(id) is id")
        self.id = Identifier.string(id.replacingOccurrences(of: ".", with: "-"))
        self.rezeptID = id
        self.farbnummer = farbnummer
        self.farbton = farbton
        self.kollektion = collection

        var kostenKalk: Float = 0.0
        var preisKalk: Float = 0.0

//        do {
//            print("about to fetch Produkts")
//            let products = try Produkt.makeQuery().all()
//
//            print(anteil.count)
//            for item in anteil {
//                print("\(item.produkt) in item")
//                let anteilProdukt = products.map({ (prod) -> Produkt in
//                    print("\(prod.returnProductID()) and \(item.produkt)")
//                    if (prod.returnProductID() == item.produkt) {
//                        return prod
//                    }
//                    return Produkt(produktID: "error", name: "error")
//                })[0]
//                print(anteilProdukt.name)
//                kostenKalk += item.getKosten(produkt: anteilProdukt)
//                preisKalk += item.getVKPreis(produkt: anteilProdukt)
//            }
//
//
//        } catch let err {
//            print("err")
//        }
        
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
            do {
                
                kostenKalk += item.getKosten()
            } catch {
                print("error loading costs of \(item.produktID)")
            }
        }
        
        return kostenKalk
    }
    
    var getPrice : Float {
        var preisKalk: Float = 0.0
        
        for item in anteile {
            do {
                preisKalk += item.getVKPreis()
            } catch {
                print("error loading price of \(item.produktID)")
            }
        }
        
        return preisKalk
    }

    
    
    
    var storage: Storage = Storage()
 
    required init(row: Row) throws {
        self.id = try row.get("id")
        self.rezeptID = try row.get("rezeptID")
        self.farbnummer = try row.get("farbnummer")
        self.farbton = try row.get("farbton")
//        self.eKPreis = try row.get("eKPreis")
//        self.vKPreis = try row.get("vKPreis")
        self.produkt = try row.get("produkt")
        self.kollektion = try row.get("kollektion")
        self.anteile = try row.get("anteil")
//        self.typ = try row.get("typ")
        self.kunde = try row.get("kunde")
    }
    
    
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("rezeptID", rezeptID)
        try row.set("farbnummer", farbnummer)
        try row.set("farbton", farbton)
//        try row.set("eKPreis", eKPreis)
//        try row.set("vKPreis", vKPreis)
        try row.set("produkt", produkt)
        try row.set("kollektion", kollektion)
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
            builder.string("kollektion")
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
        try node.set("id", id)
        try node.set("rezeptID", rezeptID)
        try node.set("farbnummer", farbnummer)
        try node.set("farbton", farbton)
        try node.set("getCost", String(format: "%.2f", getCost))
        try node.set("getPrice", String(format: "%.2f", getPrice))
        try node.set("produkt", produkt)
        try node.set("kunde", kunde)
        try node.set("kollektion", kollektion)
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
