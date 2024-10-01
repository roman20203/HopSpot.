//
//  manager_profile_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-08-22.
//

import SwiftUI

struct manager_profile_view: View {
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var showingClubSelection = false
    @State private var showingLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Profile Options")
                        .foregroundStyle(.primary) // Dynamically adapts to light and dark mode
                    ) {
                        // Button to change the selected club
                        Button(action: {
                            showingClubSelection = true
                        }) {
                            Text("Change Club")
                                .foregroundStyle(AppColor.color) // Highlight color
                                .font(.headline) // Optional: Make text a bit more prominent
                        }
                        .sheet(isPresented: $showingClubSelection) {
                            InAppClubSelection()
                        }

                        // Button to log out
                        Button(action: {
                            showingLogoutConfirmation = true
                        }) {
                            Text("Log Out")
                                .foregroundStyle(.red) // Red color for the log out button
                                .font(.headline) // Optional: Make text a bit more prominent
                        }
                        .alert(isPresented: $showingLogoutConfirmation) {
                            Alert(
                                title: Text("Log Out")
                                    .foregroundStyle(.primary), // Dynamically adapts to light and dark mode
                                message: Text("Are you sure you want to log out?")
                                    .foregroundStyle(.primary), // Dynamically adapts to light and dark mode
                                primaryButton: .destructive(Text("Log Out")) {
                                    viewModel.signOut()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
            }
            .background(Color.black.ignoresSafeArea()) // Black background for the entire view
            .foregroundStyle(.primary) // Dynamically adapts to light and dark mode
            .navigationTitle("Manager Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setNavigationBarAppearance()
            }
        }
    }
    
    private func setNavigationBarAppearance() {
        let appearance = UINavigationBar.appearance()
        appearance.barTintColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label] // Adapts to light and dark mode
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label] // Adapts to light and dark mode
    }
}

#Preview {
    manager_profile_view()
        .environmentObject(log_in_view_model())
}

