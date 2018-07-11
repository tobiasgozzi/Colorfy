//
//  Suchergebnis.swift
//  App
//
//  Created by Tobias Gozzi on 18/06/2018.
//

import Foundation
import Vapor

struct Suchergebnis {
    var farbton : String
    var kunde : String
    var farbnummer : String
    var rezeptID : String
    var produkt : String
    
    subscript(index: Int) -> String {
        var returnValue = ""
        switch index {
        case 0:
            returnValue = farbton
            break;
        case 1:
            returnValue = kunde
            break;
        case 2:
            returnValue = farbnummer
            break;
        case 3:
            returnValue =  produkt
            break;
        case 4:
            returnValue =  rezeptID
            break;
        default:
            returnValue =  ""
            break;
        }

        return returnValue

    }
}


extension Suchergebnis : NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("farbton", farbton)
        try node.set("kunde", kunde)
        try node.set("farbnummer", farbnummer)
        try node.set("rezeptID", rezeptID)
        try node.set("produkt", produkt)
        return node
    }
}
