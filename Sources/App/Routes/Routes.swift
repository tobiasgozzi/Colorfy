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
        let rezepteingabeController = RezeptEingabeController(drop: self)
        
        //Signup View anzeigen
        get("signup", handler: benutzerController.getRegisterView)
        
        //user wird durch Formular registriert
        post("signup", handler: benutzerController.saveUser)
        
        
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
        authRoute.get("userInfo", handler: benutzerController.showUserInfoPage)
        authRoute.post("deleteUsers") { (req) in
            try Benutzer.revert(Benutzer.database!)
            print(try Benutzer.count())
            return try self.view.make("signup")
        }
        authRoute.post("updatePassword", handler: benutzerController.updatePassword)
        
//        authRoute.post("searchRecipe", handler: rezeptsuche.searchInIE)
        authRoute.get("insert-recipe", handler: rezepteingabeController.showFormPage)
        authRoute.post("modifyRecipe", handler: rezepteingabeController.showFormPage)
        
        authRoute.post("sendNewRecipe", handler: rezepteingabeController.elaborateNewRecipe)
        
        authRoute.socket("allowUpdateQuantity", handler: rezeptausleseController.updateQuantity)
        
        authRoute.socket("lookForRecipe") { (req, ws) in
            
            let userAgent = req.headers["User-Agent"]
            print(userAgent)
//            print((req.formURLEncoded?["searchTermText"]?.string)!)
//
//
//            guard let answer = rezeptsuche?.compareRecipeWithSearchphrase(input: (req.formURLEncoded?["searchTermText"]?.string)!) else  {
//                return
//            }

//            var timer = Timer.init(timeInterval: TimeInterval.init(1), target: self, selector: Selector("sendPing"), userInfo: nil, repeats: true)
//            func sendPing() {
//                do {
//                    try ws.ping()
//                    print("ping sent")
//                } catch let e {
//                    print(e)
//                }
//            }
//            timer.fire()
            
            
                //            try ws.send("ws sends")
                
                ws.onText = { ws, text in
                    
                    let answer = rezeptsuche.compareRecipeWithSearchphrase(input: text)
                    
                    try ws.send(answer)
                }

            
            

            
        }
        
        authRoute.get("import-page", handler: importController.loadPage)
        
        
        authRoute.post("importDatabase", handler: importController.elaborateLoadedFile)
        authRoute.post("importProducts", handler: importController.importProductsFromJson)
        authRoute.post("deleteProducts", handler: importController.deleteProducts)
        authRoute.post("deleteDatabase", handler: importController.eraseDatabase)

        
        
        
    }
}
