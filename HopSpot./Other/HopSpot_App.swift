//
//  HopSpot_App.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-03.
//
import FirebaseCore
import SwiftUI
import MapKit
import Firebase

@main
struct HopSpot_App: App {
    @StateObject var viewModel = log_in_view_model()
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
