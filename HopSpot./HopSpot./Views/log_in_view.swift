//
//  log_in_view.swift
//  HopSpot.
//
//  Created by Mina Mansour on 2024-07-11.
//

import SwiftUI


struct log_in_view: View {
    
    
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        
        NavigationStack{
            ZStack{
                
                Text("HopSpot.")
                    .font(.system(size: 45, weight: .black))
                    .tracking(1.35)
                    .foregroundColor(.black)
                    
            }
            
            VStack {
                //image
                Image("rabbit_logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250, height: 90)
                    .padding(.vertical, 32)
                 
                
                //form fields
                
                
                VStack(spacing: 24){
                    InputView(text: $email, title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    
                    InputView(text: $password, 
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                }
                
                .padding(.horizontal)
                .padding(.top, 30)
                
                //sign in button
                
                Button {
                    print("Log user in..")
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color.pink)
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top, 24)
                
                
                
                
                Spacer()
                
                
                //sign up button
                
                NavigationLink {
                    
                } label: {
                    
                    HStack(spacing: 3){
                        Text("Don't have an account?")
                        Text("Sign Up!")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        
                        
                    }
                    
                    .font(.system(size: 14))
                    .foregroundColor(.pink)
                    
                }
                
                
                
                
            }
            
        }
        
    }
    
}


#Preview {
    log_in_view()
}
