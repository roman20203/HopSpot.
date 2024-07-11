//
//  register_view_model.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-10.
//

import Foundation

class register_view_model: ObservableObject{
    
    @Published var email = ""
    @Published var password = ""
    @Published var gender = ""
    @Published var age: Int = 0
    @Published var username = ""
    @Published var errormessage = ""
    
    init(){}
    
    func register(){
        guard validate() else{
            return
        }

        //register the user with firebase
    }
    
    private func validate() -> Bool{
        //age must be 19+
        //makes sure that email and password is not blank
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else{
            errormessage = "Please fill out all fields"
            return false
        }
        guard email.contains("@"), email.contains(".") else{
            errormessage = "Not a valid email"
            return false
        }
        guard age >= 19 else{
            errormessage = "Not of legal drinking age"
            return false
        }
        return true
        
    }
    
}
