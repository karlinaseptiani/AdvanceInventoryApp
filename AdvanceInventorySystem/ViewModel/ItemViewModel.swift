//
//  ItemViewModel.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 26/12/24.
//


import Foundation
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore

@MainActor
class ItemViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {
        Task {
            items.removeAll()
            await fetchItems()
        }
    }

    // Mendapatkan semua item
    func fetchItems() {
        items.removeAll()
        db.collectionGroup("items").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            self.items = documents.compactMap { try? $0.data(as: Item.self) }

            // Print all fetched items
            print("DEBUG: Fetched all items:")
            for item in self.items {
                print("- \(item.name): Quantity \(item.stock), SupplierID \(item.supplierID),  userID \(item.userID)")
            }

        }
    }

    // Fetch items for a specific supplier
    func fetchItems(for supplierID: String) {
        items.removeAll()
        db.collection("suppliers")
            .document(supplierID)
            .collection("items")
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.items = documents.compactMap { try? $0.data(as: Item.self) }
                // Print all fetched items
                print("DEBUG: Fetched all items:")
                for item in self.items {
                    print("- \(item.name): Quantity \(item.stock), SupplierID \(item.supplierID),  userID \(item.userID)")
                }

            }
    }

    // Add a new item to a supplier
    func addItem(to supplierID: String, item: Item, imageData: Data) async {
        do {
            // Upload image to Firebase Storage
            let imageRef = storage.reference().child("itemImages/\(UUID().uuidString).jpg")
            let _ = try await imageRef.putDataAsync(imageData)
            let imageURL = try await imageRef.downloadURL().absoluteString
            
            // Add item to Firestore
            var newItem = item
            newItem.imageURL = imageURL
            let _ = try db.collection("suppliers").document(supplierID).collection("items").addDocument(from: newItem)
            
//            await fetchItems(for: supplierID)
        } catch {
            print("DEBUG: Failed to add item \(error.localizedDescription)")
        }
    }

    // Edit an item 
    func editItem(for supplierID: String, item: Item, newImageData: Data?) async {
        guard let id = item.id else { return }
        do {
            var updatedItem = item
            
            if let newImageData = newImageData {
                if let oldImageURL = item.imageURL {
                    let oldImageRef = storage.reference(forURL: oldImageURL)
                    try await oldImageRef.delete()
                }

                let imageRef = storage.reference().child("itemImages/\(UUID().uuidString).jpg")
                let _ = try await imageRef.putDataAsync(newImageData)
                let newImageURL = try await imageRef.downloadURL().absoluteString
                updatedItem.imageURL = newImageURL
            }
            
            try db.collection("suppliers").document(supplierID).collection("items").document(id).setData(from: updatedItem)
            
            await fetchItems(for: supplierID)
        } catch {
            print("DEBUG: Failed to edit item \(error.localizedDescription)")
        }
    }

    
    // MARK: unused function
    // Update an item for a specific supplier
    func updateItem(for supplierID: String, item: Item) async {
        guard let id = item.id else { return }
        do {
            try db.collection("suppliers").document(supplierID).collection("items").document(id).setData(from: item)
            await fetchItems(for: supplierID)
        } catch {
            print("DEBUG: Failed to update item \(error.localizedDescription)")
        }
    }
    
    // Delete item
    func deleteItem(from supplierID: String, imageURL : String?, itemID: String) async {
        do {
            
            let transactionsCollection = db.collection("suppliers")
                .document(supplierID)
                .collection("items")
                .document(itemID)
                .collection("transactions")
            
            let snapshot = try await transactionsCollection.getDocuments()
            for document in snapshot.documents {
                try await document.reference.delete()
            }

            if let oldImageURL = imageURL {
                let oldImageRef = storage.reference(forURL: oldImageURL)
                try await oldImageRef.delete()
            }


            try await db.collection("suppliers").document(supplierID).collection("items").document(itemID).delete()
            
        } catch {
            print("DEBUG: Failed to delete item \(error.localizedDescription)")
        }
    }
}
