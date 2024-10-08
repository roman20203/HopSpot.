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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var viewModel = log_in_view_model()
    @StateObject var userLocation = UserLocation()
    @StateObject var clubHandler = club_firebase_handler()
    @StateObject var appState = AppState()
    
   
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(userLocation)
                .environmentObject(clubHandler)
                .environmentObject(appState)
        }
    }
}

