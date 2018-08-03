//
//  BenutzerController.swift
//  App
//
//  Created by Tobias Gozzi on 26/04/2018.
//
import Foundation
import Vapor
import FluentProvider
import AuthProvider

final class BenutzerController {
    
    let drop: Droplet
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func getRegisterView(_ req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("signup")
    }
    func saveUser(_ req: Request) throws -> ResponseRepresentable {
        guard
            let benutzer = req.formURLEncoded?["username"]?.string,
            let password = req.formURLEncoded?["password"]?.string,
            let rechte = req.formURLEncoded?["type"]?.string
            else {
                return "either email or password is missing"
        }
        guard
            try Benutzer.makeQuery().filter("benutzerName", benutzer).first() == nil
            else {
                return "email already exists"
        }
        
        let user = Benutzer(benutzerName: benutzer, benutzerPW: password, benutzerrechte: rechte)
        try user.save()
        
        let info = try Benutzer.makeQuery().filter("benutzerName", benutzer).first()
        print((info?.benutzerName)! + "found")
        
        return Response(redirect: "/login")
    }
    
    
    
    func showLogin(_ req: Request) throws -> ResponseRepresentable {
        

        return try drop.view.make("login")
    }
    
    func logoutUser(req: Request) throws -> ResponseRepresentable {
        
        do {
            try req.auth.unauthenticate()
        } catch let err as AuthError {
            print(err.debugDescription)
        }
            
        return try drop.view.make("login")
    }
    
    func loginUser(_ req: Request) throws -> ResponseRepresentable {
        
        guard
            let username = req.formURLEncoded?["username"]?.string,
            let password = req.formURLEncoded?["password"]?.string
            else {
                return "either email or password is missing"
        }
        let credentials = Password(username: username, password: password)


        let benutzer = try Benutzer.makeQuery().filter("benutzerName", username).all()
        
        if (benutzer.count > 0) {
            do {
                // returns matching user (throws error if user doesn't exist)
                
                let user = try Benutzer.authenticate(credentials)
                
                // persists user and creates a session cookie
                let authenticatedUser = req.auth.authenticate(user)
                
                return try drop.view.make("main",["benutzer": user])
                
            } catch {
                let message = "Password sbagliata"
                let divAttributes = " class=\"alert alert-danger\" role=\"alert\""
                return try drop.view.make("login",["loginResult" : message, "resultType" : divAttributes])
            }
        } else {
            let message = "Utente non trovato"
            let divAttributes = " class=\"alert alert-danger\" role=\"alert\""
            return try drop.view.make("login",["loginResult" : message, "resultType" : divAttributes])
        }
    }
    
    func loadSecuredLogin(_ req: Request) throws -> ResponseRepresentable {
        print("reached main site")
        let user: Benutzer = try req.auth.assertAuthenticated()

        return try drop.view.make("main", ["benutzer": try user.makeNode(in: nil)])
    }
    
    func showUserInfoPage(_ req: Request) throws -> ResponseRepresentable {
        
        
        let user: Benutzer = try req.auth.assertAuthenticated()
        return try drop.view.make("userInfo", ["benutzer": try user.makeNode(in: nil)])
    }
    
    func updatePassword(_ req : Request) throws -> ResponseRepresentable {
        
        let user: Benutzer = try req.auth.assertAuthenticated()
        
        if let newPassword = req.formURLEncoded?["pwd"] {
            if let confirmPassword = req.formURLEncoded?["pwdConfirmation"] {
                print("password is the same \(newPassword == confirmPassword): \(newPassword.wrapped)")
                
                if let checkedPw = newPassword.wrapped.string, checkedPw != "" && checkedPw.count>3 {
                    user.benutzerPW = checkedPw
                    try user.save()
                    return try drop.view.make("userInfo", ["benutzer": try user.makeNode(in: nil), "message" : "Password aggiornata con successo.", "result" : "success" ])
                } else {
                    return try drop.view.make("userInfo", ["benutzer": try user.makeNode(in: nil), "message" : "Password troppo corto, deve contenere almeno 3 caratteri.", "result" : "tooShort" ])

                }
                
            }
        }
        
        return try drop.view.make("userInfo", ["benutzer": try user.makeNode(in: nil), "message" : "Errore durante il salvataggio.", "result" : "error" ])
    }
}


