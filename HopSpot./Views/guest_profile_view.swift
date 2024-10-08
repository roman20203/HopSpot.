//
//  guest_profile_views.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-10-08.
//
import SwiftUI

struct guest_profile_view: View {
    @EnvironmentObject var appState: AppState  // Use AppState to handle guest mode

    var body: some View {
        VStack {
            Text("Guest Profile")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)  // Text color set to white
                .padding(.bottom, 20)
            
            Text("You are currently logged in as a guest.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)  // Text color set to gray for a softer contrast
                .padding(.horizontal)

            Button(action: {
                appState.logoutGuest()  // Leave guest mode and return to the login view
            }) {
                Text("Leave Guest Mode")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)  // Text color for button
                    .frame(width: 200, height: 48)
                    .background(AppColor.color)
                    .cornerRadius(10)
            }
            .padding(.bottom, 40)
        }
        .padding()
        .background(Color.black.ignoresSafeArea())  // Set background to black
    }
}

#Preview {
    NavigationStack {
        guest_profile_view()
            .preferredColorScheme(.dark)  // Force dark mode in preview
            .environmentObject(AppState())  // Provide AppState for preview
    }
}
