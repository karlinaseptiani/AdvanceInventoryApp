//
//  AuthenticationFormProtocol.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 23/12/24.
//


import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: Account?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await getUser()
        }
    }
    
    func login(email: String, password: String) async throws {
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await getUser()
        } catch {
            print("Failed to sign in : \(error.localizedDescription)")
        }
        
    }
    
    func register(email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = Account(id: result.user.uid, fullname: fullname, email: email)
            
            let encodeUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodeUser)
            
            await getUser()
        } catch {
            print("Failed to create user : \(error.localizedDescription)")
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to sign : \(error.localizedDescription)")
        }
    }
        
    func getUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else  { return }
        self.currentUser = try? snapshot.data(as: Account.self)

        
        print("Current user = \(self.currentUser)")
    }
    
}
