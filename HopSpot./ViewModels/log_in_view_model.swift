//
//  log_in_view_model.swift
//  HopSpot.
//
//  Created by Mina Mansour on 2024-07-10.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class log_in_view_model: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?

    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        self.userSession = Auth.auth().currentUser
        // Set up listener for authentication state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.userSession = user
                Task {
                    await self?.fetchUser()
                }
            }
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to sign in with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String, joined: Date, birthdate: Date, gender: Gender) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let user = User(fullname: fullname, id: result.user.uid, email: email, password: password, joined: joined, birthdate: birthdate, gender: gender)
            let encodeduser = try Firestore.Encoder().encode(user)
            
            try await Firestore.firestore().collection("users").document(user.id).setData(encodeduser)
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() // Signs out user in backend
            self.userSession = nil // Wipes out user session
            self.currentUser = nil // Wipes out current user data model
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else { return }
        
        do {
            // Delete user from Firestore
            try await Firestore.firestore().collection("users").document(user.uid).delete()
            // Delete user from Firebase Auth
            try await user.delete()
            signOut()
        } catch {
            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No authenticated user found")
            signOut() // Sign out if no user is authenticated
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            
            if snapshot.exists {
                self.currentUser = try snapshot.data(as: User.self)
                print("DEBUG: Successfully fetched user: \(String(describing: self.currentUser))")
            } else {
                print("DEBUG: User document does not exist")
                signOut() // Sign out if user document is missing
            }
        } catch {
            print("DEBUG: Failed to fetch user with error: \(error.localizedDescription)")
            signOut() // Sign out on error
        }
    }
    
    deinit {
        // Remove the authentication state listener when the view model is deinitialized
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
