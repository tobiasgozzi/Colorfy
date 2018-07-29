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
        // returns matching user (throws error if user doesn't exist)
        print("about to try authentification for \(username)")

        let user = try Benutzer.authenticate(credentials)

        // persists user and creates a session cookie
        req.auth.authenticate(user)
        
        
        print(user.benutzerName + " authenticated")
        
        return try drop.view.make("main",["benutzer": user])
    }
    
    func loadSecuredLogin(_ req: Request) throws -> ResponseRepresentable {
        print("reached main site")
        let user: Benutzer = try req.auth.assertAuthenticated()

        return try drop.view.make("main", ["benutzer": try user.makeNode(in: nil)])
    }
}


