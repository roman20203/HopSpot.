//
//  reg_or_log.swift
//  HopSpot.
//
//  Created by HopSpot on 2024-07-01.
//

import SwiftUI
import SwiftData

struct reg_or_log: View {
    var body: some View {
        ZStack {
            Text("HopSpot.")
                //.font(.custom("arial_black", size: 45))
                .font(.system(size: 45, weight: .black))
                .tracking(1.35)
                .foregroundColor(.black)
                .offset(x: -0.50, y: -336.50)
            
            Text("Lets Get Started ")
                .font(.system(size: 35, weight: .black))
                .tracking(1.20)
                .foregroundColor(.black)
                .offset(x: 6.50, y: -5)
            
            Text("Get ready to find the perfect spot for you.")
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(width: 300)
                .tracking(0.60)
                .foregroundColor(.black)
                .offset(x: -0.50, y: 56)
            
            VStack {
                
                Button(action: signUp) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(width: 358, height: 56)
                        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                        .cornerRadius(26)
                }
                .offset(x: 0, y: -10)
                
                Text("Already have an account? ")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(0.48)
                    .foregroundColor(.black)
                    .offset(x: 0.50, y: 0.50)
                
                // Sign In Button
                Button(action: logIn) {
                    Text("Log In")
                        .foregroundColor(.white)
                        .frame(width: 358, height: 56)
                        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                        .cornerRadius(26)
                }
                .offset(x: 0, y: 0)
                
            }
            .frame(width: 358, height: 162)
            .offset(x: 0, y: 209)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 153, height: 77)
                .background(
                    Image("rabbit_logo")
                        .offset(x: 6.50, y: -159.50)
                )
        }
        .frame(width: 390, height: 844)
        .background(Color.white)
    }
    
    // Function to handle Sign In action
    func logIn() {
        // Perform sign in logic here

        print("Log In button tapped")
    }
    func signUp() {
        // Perform sign in logic here
        //Go to sign up page
        print("Sign Up button tapped")
    }
    
}

#Preview {
    reg_or_log()
}
