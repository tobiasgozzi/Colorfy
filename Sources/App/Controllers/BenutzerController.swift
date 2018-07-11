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
            let password = req.formURLEncoded?["password"]?.string
            else {
                return "either email or password is missing"
        }
        guard
            try Benutzer.makeQuery().filter("benutzerName", benutzer).first() == nil
            else {
                return "email already exists"
        }
        
        let user = Benutzer(benutzerName: benutzer, benutzerPW: password)
        try user.save()
        
        let info = try Benutzer.makeQuery().filter("benutzerName", benutzer).first()
        print((info?.benutzerName)! + "found")
        
        return Response(redirect: "/login")
    }
    
    
    
    func showLogin(_ req: Request) throws -> ResponseRepresentable {
        
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
        print(" about to try authentification \(Benutzer.usernameKey)")

        let user = try Benutzer.authenticate(credentials)
        // persists user and creates a session cookie
        req.auth.authenticate(user)
        print(user.benutzerName + " authenticated")
        return Response(redirect: "/main")
        
        //        let list = try Benutzer.all()
        //        print(list.count)
        //        print(list.last?.benutzerName)
        //        return try drop.view.make("main", ["benutzer": list.makeNode(in: nil)])
    }
    
    
    
    
    func showMain(_ req: Request) throws -> ResponseRepresentable {
        let list = try Benutzer.all()
        print(list.count)
        print(list.last?.benutzerName)
        return try drop.view.make("main", ["benutzer": list.makeNode(in: nil)])
    }
    
    func loadSecuredLogin(_ req: Request) throws -> ResponseRepresentable {
        print("reachedLogin")
        let user: Benutzer = try req.auth.assertAuthenticated()
        return try drop.view.make("main", ["benutzer": try user.makeNode(in: nil)])
    }
}


