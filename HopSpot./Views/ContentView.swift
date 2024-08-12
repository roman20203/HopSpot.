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
