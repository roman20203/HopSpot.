//
//  AppState.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-10-08.
//
import SwiftUI

class AppState: ObservableObject {
    @Published var isGuest: Bool = false
    
    // Call this to switch to guest mode
    func continueAsGuest() {
        isGuest = true
    }
    
    // Call this to log out the guest and return to login screen
    func logoutGuest() {
        isGuest = false
    }
}
