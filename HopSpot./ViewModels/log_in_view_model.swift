//
//  log_in_view_model.swift
//  HopSpot.
//
//  Created by Mina Mansour  on 2024-07-10.
//

import Foundation
import Firebase

class log_in_view_model: ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    
    
    init(){
        
    }
    func signIn(withEmail email: String, password: String) async throws {
        
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        
    }
    
    func signOut(){
        
    }
    func deleteAccount(){
        
    }
    func fetchUser(){
        
    }
}
