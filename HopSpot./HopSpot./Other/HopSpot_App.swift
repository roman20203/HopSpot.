//
//  HopSpot_App.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-03.
//
import FirebaseCore
import SwiftUI
import MapKit

@main
struct HopSpot_App: App {
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
