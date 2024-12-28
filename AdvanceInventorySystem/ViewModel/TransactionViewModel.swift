//
//  TransactionViewModel.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 26/12/24.
//

import SwiftUI

import Foundation
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func fetchTransactions(idSupplier supplierID: String, idItem itemID: String) async {
        transactions.removeAll()
        do {
            let snapshot = try await db.collection("suppliers")
                .document(supplierID)
                .collection("items")
                .document(itemID)
                .collection("transactions")
                .getDocuments()
            
            self.transactions = try snapshot.documents.compactMap { try $0.data(as: Transaction.self) }
            
            // Debug print
            print("DEBUG: Fetched transactions for itemID \(itemID) under supplierID \(supplierID):")
            for transaction in transactions {
                print("- \(transaction.itemName): \(transaction.quantity) \(transaction.type) on \(transaction.date)")
            }
        } catch {
            print("DEBUG: Failed to fetch transactions \(error.localizedDescription)")
        }
    }

    func addTransaction(idSupplier supplierID: String, idItem itemID: String, transaction: Transaction) async {
        
        let newTransaction = transaction
        
        do {
            let _ = try db.collection("suppliers")
                .document(supplierID)
                .collection("items")
                .document(itemID)
                .collection("transactions")
                .addDocument(from: newTransaction)
            
            await updateStock(idSupplier: supplierID, idItem: itemID, change: transaction.quantity)
            await fetchTransactions(idSupplier: supplierID, idItem: itemID)

        } catch {
            print("DEBUG: Failed to add transaction \(error.localizedDescription)")
        }
    }
    
    func updateStock(idSupplier supplierID: String, idItem itemID: String, change: Int) async {
        do {
            // Fetch the item document
            let itemRef = db.collection("suppliers")
                .document(supplierID)
                .collection("items")
                .document(itemID)
            
            let document = try await itemRef.getDocument()
            
            guard let data = document.data(), var item = try? document.data(as: Item.self) else {
                print("DEBUG: Item not found for stock update.")
                return
            }
            
            // Update the stock
            item.stock += change
            try itemRef.setData(from: item)
            
            print("DEBUG: Stock updated for item \(item.name) by \(change). New stock: \(item.stock)")
        } catch {
            print("DEBUG: Failed to update stock \(error.localizedDescription)")
        }
    }

}
