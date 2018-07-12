import Foundation
import Vapor
import FluentProvider
import AuthProvider

final class Benutzer : Model, JSONRepresentable {
    func makeJSON() throws -> JSON {
        <#code#>
    }
    
//    - benutzerechte : BenutzerRechte
    var benutzerID : String
    var benutzerName : String
    var benutzerPW : String
//    - benutzerGueltigBis : Date
//    - benutzerSeit : Date
//    - benutzerIP : []Int
//    - benutzerSprache : Benutzerprache
//
    
    static var usernameKey: String {
        return "benutzerName"
    }
    
    static var passwordKey: String {
        return "benutzerPW"
    }
    
    
    let storage = Storage()
    
    init(row: Row) throws {
        benutzerName = try row.get("benutzerName")
        benutzerPW = try row.get("benutzerPW")
        benutzerID = try row.get("benutzerID")
    }
    
    init(benutzerID: String, benutzerName: String, benutzerPW: String) {
        self.benutzerID = benutzerID
        self.benutzerName = benutzerName
        self.benutzerPW = benutzerPW
    }
    
    convenience init(benutzerName: String, benutzerPW: String) {
        self.init(benutzerID: Date.init().description, benutzerName: benutzerName, benutzerPW: benutzerPW)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("benutzerName", benutzerName)
        try row.set("benutzerPW", benutzerPW)
        try row.set("benutzerID", benutzerID)
        return row
    }
    
    
}


extension Benutzer: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("benutzerName")
            builder.string("benutzerID")
            builder.string("benutzerPW")

        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


// MARK: Node
extension Benutzer: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("benutzerID", benutzerID)
        try node.set("benutzerName", benutzerName)
        try node.set("benutzerPW", benutzerPW)
        return node
    }
}

extension Benutzer: PasswordAuthenticatable {}
extension Benutzer: SessionPersistable {}
