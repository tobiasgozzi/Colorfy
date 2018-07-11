//
//  Rezeptsuche.swift
//  App
//
//  Created by Tobias Gozzi on 14/05/2018.
//

import Foundation

class RezeptsucheController {
    
    
    var filerobjekt: Filterobjekt? = nil
    var suchergebnis : [Rezept] = []
    
    let drop: Droplet
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func findRecieps(_ req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("signup")
    }
    
    func filterResults(){
        for item in suchergebnis {
            if let fbnr = filerobjekt?.getFarbtonCollection(),  fbnr == item.farbnummer {
                
            }
            if let knd = filerobjekt?.getKunde(), knd == item.kunde {
                
            }
            if let frbt = filerobjekt?.getFarbton(), frbt == item.farbton {
                
            }
        }
    }
    
    func compareRecipeWithSearchphrase(input: String) -> String {
        var JSONcontent = "<div class='rTable'><div class='rTableRow'><div class='rTableHead'><strong>Tinta</strong></div><div class='rTableHead'><span style='font-weight: bold;'>Prodotto</span></div><div class='rTableHead'><span style='font-weight: bold;'>Colore</span></div><div class='rTableHead'><span style='font-weight: bold;'>Cliente</span></div></div>"

        do {
            
            print(Rezept.idKey)
            print(Rezept.entity)
            print(Rezept.idType)
            print(Rezept.name)

//            Rezept.database!.query(Rezept).filter()
            
            let query = try Rezept.makeQuery().filter("farbnummer", .contains, input)
//            if let query = try Rezept.makeQuery().filter("field", .contains, input) {
            let count = try query.count()
            if (count > 0) {
                
                let queryFetch = try query.all()
                
                for (index, rezept) in queryFetch.enumerated() {
                    let result = Suchergebnis(farbton: rezept.farbton, kunde: rezept.kunde, farbnummer: rezept.farbnummer, rezeptID: rezept.rezeptID, produkt: rezept.produkt)
                
                
                    JSONcontent.append(generateRecipeHtmlSniplet(match: result, currentItem: index))
                }
            } else {
                JSONcontent.append("nothing found for \(input)")
            }
            
        
        } catch let error {
            print(error.localizedDescription)
        }
        
//        generateRecipeHtmlSniplet(match: match)
        
        JSONcontent.append((JSONcontent != "") ? "</div></div>" : "")
        return JSONcontent != "" ? JSONcontent : "nothing found"
        
    }
    
    
//    <div class="rTable">
//    <div class="rTableRow">
//    <div class="rTableHead">
//    <strong>Tinta</strong>
//    </div>
//    <div class="rTableHead">
//    <span style="font-weight: bold;">Prodotto</span>
//    </div>
//    <div class="rTableHead">
//    <span style="font-weight: bold;">Colore</span>
//    </div>
//    <div class="rTableHead">
//    <span style="font-weight: bold;">Cliente</span>
//    </div>
//    </div>
//    <div class="rTableRow">
//    <div class="rTableCell">Ral 3003
//    </div>
//    <div class="rTableCell">
//    Bluefin Softmatt
//    </div> <div class="rTableCell">
//    Blu
//    </div>
//    <div class="rTableCell">
//    Mattioli
//    </div>
//
//    </div>
//    </div>

    
    func generateRecipeHtmlSniplet(match: Suchergebnis, currentItem: Int) -> String {
        
        func evenOrUneven(nr : Int) -> String {
            if (nr % 2 != 0) {
                return "style='background-color:grey;'"
            } else  {
                return ""
            }
        }
        
        let linkHead = "<a href='recipe/\(match[4])'>"
        let openTrHead = "<div class='rTableRow'"
        let openTrTail = ">"
        let closeTr = "</div>"
        let openTd = "<div class='rTableCell'>"
        let closeTd = "</div>"
        let linkTail = "</a>"

        var htmlLine = ""

        htmlLine.append(linkHead + openTrHead + evenOrUneven(nr: currentItem) + openTrTail)

        for i in 0...4 {
            htmlLine.append(openTd)
            htmlLine.append(match[i])
            htmlLine.append(closeTd)
        }
        htmlLine.append(closeTr + linkTail)

        return htmlLine
    }
    
}
