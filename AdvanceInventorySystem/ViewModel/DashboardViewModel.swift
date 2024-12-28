//
//  DashboardViewModel.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 27/12/24.
//


import FirebaseCore
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var totalItems: Int = 0
    @Published var totalSuppliers: Int = 0
    @Published var items: [Item] = []

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

        init() {
            Task {
                await fetchTotalItems()
                await fetchTotalSuppliers()
            }
        }

    
    func fetchTotalItems() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collectionGroup("items").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.totalItems = 0

            self.items = documents.compactMap { try? $0.data(as: Item.self) }

            for item in self.items {
                if item.userID == userID {
                    self.totalItems += 1
                }
            }

        }

    }
    
    func fetchTotalSuppliers() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        do {
            let suppliersSnapshot = try await db.collection("suppliers")
                .whereField("userID", isEqualTo: userID)
                .getDocuments()
            
            totalSuppliers = suppliersSnapshot.documents.count
        } catch {
            print("Error fetching total suppliers: \(error)")
        }
    }


}
