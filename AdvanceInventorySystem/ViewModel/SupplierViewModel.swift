//
//  SupplierViewModel.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 26/12/24.
//


import Foundation
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SupplierViewModel: ObservableObject {
    @Published var suppliers: [Supplier] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {
        Task {
            await fetchSuppliers()
        }
    }
    
    // get suppliers
    func fetchSuppliers() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await db.collection("suppliers")
                .whereField("userID", isEqualTo: userID)
                .getDocuments()
            
            self.suppliers = try snapshot.documents.compactMap { try $0.data(as: Supplier.self) }
        } catch {
            print("DEBUG: Failed to fetch suppliers \(error.localizedDescription)")
        }
    }
    
    // create supplier
    func addSupplier(supplier: Supplier) async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        var newSupplier = supplier
        newSupplier.userID = userID
        
        do {
            let _ = try db.collection("suppliers").addDocument(from: newSupplier)
            await fetchSuppliers()
        } catch {
            print("DEBUG: Failed to add supplier \(error.localizedDescription)")
        }
    }
    
    // Delete supplier
    func deleteSupplier(supplierID: String) async {
        do {
            let itemsCollection = db.collection("suppliers").document(supplierID).collection("items")
            
            let itemsSnapshot = try await itemsCollection.getDocuments()
            
            for document in itemsSnapshot.documents {
                try await document.reference.delete()
            }
            
            try await db.collection("suppliers").document(supplierID).delete()
            
            await fetchSuppliers()
        } catch {
            print("DEBUG: Failed to delete supplier \(error.localizedDescription)")
        }
    }

    // Update supplier
    func updateSupplier(supplier: Supplier) async {
        guard let id = supplier.id else { return }
        do {
            try db.collection("suppliers").document(id).setData(from: supplier)
            await fetchSuppliers()
        } catch {
            print("DEBUG: Failed to update supplier \(error.localizedDescription)")
        }
    }

}
