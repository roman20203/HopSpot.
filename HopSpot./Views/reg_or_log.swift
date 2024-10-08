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
        NavigationView {
            ZStack {
                AppColor.color
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Main Title
                    Text("HopSpot.")
                        .font(.system(size: 45, weight: .black))
                        .tracking(1.35)
                        .foregroundStyle(.black)
                        .padding(.top, 100) // Adjusted padding
                    // Logo
                    Image("rabbit_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 100)
                        .padding(.bottom, 50) // Adjusted padding

                    Text("Let's Get Started")
                        .font(.system(size: 35, weight: .black))
                        .tracking(1.20)
                        .foregroundStyle(.black)
                        .padding(.top, 10) // Adjusted padding

                    Text("Get ready to find the perfect spot for you.")
                        .font(.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                        .tracking(0.60)
                        .foregroundStyle(.black)
                        .padding(.top, 20) // Adjusted padding

                    // Buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: register_view()) {
                            Text("Sign Up")
                                .foregroundStyle(.white)
                                .frame(width: 358, height: 56)
                                .background(Color.blue)
                                .cornerRadius(26)
                        }

                        Text("Already have an account?")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(0.48)
                            .foregroundStyle(.black)

                        NavigationLink(destination: log_in_view()) {
                            Text("Log In")
                                .foregroundStyle(.white)
                                .frame(width: 358, height: 56)
                                .background(SignInColor.color)
                                .cornerRadius(26)
                        }
                    }
                    .padding(.top, 50) // Adjusted padding

                    Spacer()

                }
            }
        }
        .accentColor(AppColor.color) // Set the color of the selected tab icon
    }
}


#Preview {
    reg_or_log()
        .environmentObject(log_in_view_model())
}

