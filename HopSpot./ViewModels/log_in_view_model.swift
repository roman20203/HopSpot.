//
//  log_in_view_model.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-10.
//

import Foundation

class log_in_view_model: ObservableObject{
    
    @Published var email = ""
    @Published var password = ""
    @Published var errormessage = ""
    
    init(){}
    
    func login(){
        //makes sure that email and password is not blank
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else{
            errormessage = "Please fill out all fields"
            return
        }
        //hello
        
    }
    
    func validate(){
        
    }
    
    
}
