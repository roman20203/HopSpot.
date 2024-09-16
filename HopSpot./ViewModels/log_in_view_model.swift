//
//  log_in_view_model.swift
//  HopSpot.
//
//  Created by Mina Mansour and Ben Roman on 2024-07-10.
//



import Foundation
import Firebase
import FirebaseFirestoreSwift

@MainActor
class log_in_view_model: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var currentManager: Manager? // To hold manager data if the user is a manager

    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var isListening = false
    private var isFetchingUser = false

    init() {
        attachAuthListener()
    }

    func attachAuthListener() {
        guard !isListening else { return }
        isListening = true
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.userSession = user
                if user != nil {
                    Task {
                        if !self!.isFetchingUser {
                            await self?.fetchUser()
                        }
                    }
                } else {
                    self?.signOut()
                }
            }
        }
    }

    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser() // This will determine if the user is a manager or regular user
        } catch {
            print("DEBUG: Failed to sign in with error \(error.localizedDescription)")
            throw error
        }
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No authenticated user found")
            signOut()
            return
        }

        do {
            isFetchingUser = true
            print("DEBUG: Fetching document for UID: \(uid)")

            // First, try to fetch from the "users" collection
            let userSnapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()

            if userSnapshot.exists {
                self.currentUser = try userSnapshot.data(as: User.self)
                print("DEBUG: Successfully fetched user: \(String(describing: self.currentUser))")
            } else {
                // If the document does not exist in the "users" collection, try the "BusinessManager" collection
                let managerSnapshot = try await Firestore.firestore().collection("BusinessManagers").document(uid).getDocument()
                
                

                if managerSnapshot.exists {
                    self.currentManager = try managerSnapshot.data(as: Manager.self)
                    print("DEBUG: Successfully fetched manager: \(String(describing: self.currentManager))")
                } else {
                    print("DEBUG: User document does not exist in either collection")
                    signOut()
                }
            }
        } catch {
            print("DEBUG: Failed to fetch user or manager with error: \(error.localizedDescription)")
            signOut()
        }

        // Cleanup
        isFetchingUser = false
    }

    

    func createUser(withEmail email: String, password: String, fullname: String, joined: Date, birthdate: Date, gender: Gender) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let user = User(fullname: fullname, id: result.user.uid, email: email, password: password, joined: joined, birthdate: birthdate, gender: gender, role: .regularUser)
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
            self.currentManager = nil // Wipes out manager data model if user is a manager
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
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            isListening = false
        }
    }
}

