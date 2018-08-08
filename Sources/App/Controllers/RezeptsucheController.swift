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
    
//    func findRecieps(_ req: Request) throws -> ResponseRepresentable {
//        return try drop.view.make("signup")
//    }
    
//    func searchInIE(_ req: Request) throws -> ResponseRepresentable {
//        
//        
//        let answer = compareRecipeWithSearchphrase(input: (req.formURLEncoded?["searchTermText"]?.string)!)
//        drop.log.info((req.auth.authenticated(Benutzer.self)?.benutzerID)!)
//        drop.log.info((req.formURLEncoded?["searchTermText"]?.string)!)
//        print(try drop.view.make("main", ["resultIE": answer]).makeResponse().headers["Authorization"])
//        return try drop.view.make("main", ["resultIE": answer, "titelRicettetrovate" : "Ricette trovate"])
//        
//    }
    
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
        var JSONcontent = "<div class='container' style='padding-bottom:50px;'><div class='row'><div class='col'><span style='font-weight: bold;'>Tinta</span></div><div class='col'><span style='font-weight: bold;'>Prodotto</span></div><div class='col'><span style='font-weight: bold;'>Colore</span></div><div class='col'><span style='font-weight: bold;'>Cliente</span></div></div>"

        do {
            
//            Rezept.database!.query(Rezept).filter()
            
            let query = try Rezept.makeQuery().filter("farbnummer", .contains, input.uppercased())
//            if let query = try Rezept.makeQuery().filter("field", .contains, input) {
            let count = try query.count()
            if (count > 0) {
                let queryProducts = try Produkt.makeQuery().all()

                var queryFetch : [Rezept] = []
                
                do {
                    
                    queryFetch = try query.all()

                } catch let error as NodeError {
                    print(error.suggestedFixes)
                }
                
                for (index, rezept) in queryFetch.enumerated() {
                    
                    guard let product = try Produkt.find(rezept.produkt) else {
                        print("\(rezept.produkt) not found")
                        throw Abort.notFound
                    }

                    let result = Suchergebnis(farbton: rezept.farbton, kunde: rezept.kunde, farbnummer: rezept.farbnummer, rezeptID: rezept.rezeptID, produkt: product.name)
                
                    JSONcontent.append(generateRecipeHtmlSniplet(match: result, currentItem: index))
                }
            } else {
                JSONcontent.append("Nessun risultato per \(input)")
            }
            
        
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        JSONcontent.append((JSONcontent != "") ? "</div>" : "")
        return JSONcontent != "" ? JSONcontent : "Nessun risultato"
        
    }
    
    

    
    func generateRecipeHtmlSniplet(match: Suchergebnis, currentItem: Int) -> String {
        
        func evenOrUneven(nr : Int) -> String {
            if (nr % 2 != 0) {
                return "style='background-color:#29D0FF;'"
            } else  {
                return ""
            }
        }
        
        let linkHead = "<a href='recipe/\(match[4])'>"
        let openTrHead = "<div class='row'"
        let openTrTail = ">"
        let closeTr = "</div>"
        let openTd = "<div class='col'>"
        let closeTd = "</div>"
        let linkTail = "</a>"

        var htmlLine = ""

        htmlLine.append(openTrHead + evenOrUneven(nr: currentItem) + openTrTail)

        for i in 0...3 {
            
            htmlLine.append(openTd)
            htmlLine.append("<span>")
            htmlLine.append(linkHead)
            htmlLine.append(match[i])
            htmlLine.append(linkTail)
            htmlLine.append("</span>")
            htmlLine.append(closeTd)

        }
        htmlLine.append(closeTr)

        return htmlLine
    }
    
}
