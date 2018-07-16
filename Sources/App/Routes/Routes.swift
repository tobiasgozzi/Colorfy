import Vapor
import AuthProvider
import Sessions
import JSON
import Foundation


extension Droplet {
    func setupRoutes() throws {
        
        
        let benutzerController = BenutzerController(drop: self)      // added
        let rezeptsuche = RezeptsucheController(drop: self)
        let importController = ImportController(drop: self)
        let rezeptausleseController = RezeptAusleseController(drop: self)
        
        //Signup View anzeigen
        get("signup", handler: benutzerController.getRegisterView)
        
        //user wird durch Formular registriert
        post("signup", handler: benutzerController.saveUser)
        
        
        
        //User versucht login
        //post("login", handler: benutzerController.loginUser)  // added
        
        //LoginSeite wird aufgerufen
        
        
//        self.get("erase") { req -> ResponseRepresentable in
//
//            return try self.view.make("signup")
//        }
        
        //
        //get("main", handler: benutzerController.showMain)
        //post("main", handler: benutzerController.showMain)
        
        
        
        let persistMW = PersistMiddleware(Benutzer.self)
        let memory = MemorySessions()
        let sessionMW = SessionsMiddleware(memory)
        let invRedirect = InverseRedirectMiddleware.home(Benutzer.self)
        let redirect = RedirectMiddleware.login()

        
        let loginRoute = grouped([sessionMW, persistMW, invRedirect])
        
        //inverse Redirection from login for logged in users
//        let group = self.grouped([invRedirect])
//        group.get("login") { req in
//            return try self.view.make("login")
//        }
        
        loginRoute.get("login", handler: benutzerController.showLogin)  // added)

        loginRoute.post("login", handler: benutzerController.loginUser)
        
        
        let passwordMW = PasswordAuthenticationMiddleware(Benutzer.self)
        
        let authRoute = grouped([sessionMW, persistMW, redirect, passwordMW])
        
        authRoute.get("", handler: benutzerController.loadSecuredLogin)
        authRoute.get("main", handler: benutzerController.loadSecuredLogin)
//        authRoute.get("searchRecipe") {(req) in
//
//        }

        authRoute.get("recipe", ":recipe", handler: rezeptausleseController.showRecipe)
        
        authRoute.get("logout", handler: benutzerController.logoutUser)

        authRoute.post("deleteUsers") { (req) in
            try Benutzer.revert(Benutzer.database!)
            print(try Benutzer.count())
            return try self.view.make("signup")
        }
        
        authRoute.post("searchRecipe", handler: rezeptsuche.searchInIE)
        
        authRoute.socket("updateRecipe") { (req, ws) in
            
            let userAgent = req.headers["User-Agent"]
            print(userAgent)
//            print((req.formURLEncoded?["searchTermText"]?.string)!)
//
//
//            guard let answer = rezeptsuche?.compareRecipeWithSearchphrase(input: (req.formURLEncoded?["searchTermText"]?.string)!) else  {
//                return
//            }

            

                //            try ws.send("ws sends")
                
                ws.onText = { ws, text in
                    
                    let answer = rezeptsuche.compareRecipeWithSearchphrase(input: text)
                    
                    print(text + " sent from client")
                    try ws.send(answer)
                }

            
            

            
        }
        
        authRoute.get("import-page", handler: importController.loadPage)
        
        
        authRoute.post("importDatabase", handler: importController.elaborateLoadedFile)

        authRoute.post("deleteDatabase", handler: importController.eraseDatabase)

        
        
        
    }
}
