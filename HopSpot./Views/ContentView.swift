//
//  ContentView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-03.
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: log_in_view_model

    var body: some View {
        Group {
            if viewModel.userSession != nil {
                // Check if the current user is a manager or a regular user
                if let _ = viewModel.currentManager {
                    manager_main() // Navigate to Manager's View
                } else if let _ = viewModel.currentUser {
                    main_view() // Navigate to User's View
                }
            } else {
                reg_or_log()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUser() // Fetch user data when the view appears
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(log_in_view_model()) // Provide an instance of your view model
    }
}

/*
 
 
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: log_in_view_model

    
    var body: some View {
        
        Group {
            if viewModel.userSession != nil {
                main_view()

            } else {
                reg_or_log()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUser()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(log_in_view_model()) // Provide an instance of your view model

    }
}
*/
