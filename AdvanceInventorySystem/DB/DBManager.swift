//
//  DBManager.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 18/12/24.
//


import Foundation

class DBManager {
    static let shared = DBManager()
    
    @Published var products: [Product] = []
    
    private init() {
        createTables()
    }
    
    private func createTables() {
        let productTable = """
        CREATE TABLE IF NOT EXISTS Products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        stock INTEGER,
        imagePath TEXT
        );
        """
        
        let historyTable = """
        CREATE TABLE IF NOT EXISTS Histories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        type TEXT,
        quantity INTEGER,
        date TEXT,
        FOREIGN KEY(productId) REFERENCES Products(id)
        );
        """
        
        DBHelper.shared.executeQuery(productTable)
        DBHelper.shared.executeQuery(historyTable)
    }
    
    // MARK: - Product Operations
    func insertProduct(name: String, description: String, category: String, price: Double, stock: Int, imagePath: String) {
        let query = """
        INSERT INTO Products (name, description, category, price, stock, imagePath)
        VALUES ('\(name)', '\(description)', '\(category)', \(price), \(stock), '\(imagePath)');
        """
        DBHelper.shared.executeQuery(query)
    }
    
    func fetchAllProducts() -> [Product] {
        let query = "SELECT * FROM Products"
        let results = DBHelper.shared.fetchQuery(query)
        
        return results.map {
            Product(
                id: $0["id"] as? Int ?? 0,
                name: $0["name"] as? String ?? "",
                description: $0["description"] as? String ?? "",
                category: $0["category"] as? String ?? "",
                price: $0["price"] as? Double ?? 0.0,
                stock: $0["stock"] as? Int ?? 0,
                imagePath: $0["imagePath"] as? String ?? ""
            )
            
        }
        
    }
    
    func loadDetailProducts(productId: Int) -> Product{
        let query = "SELECT * FROM Products WHERE id = \(productId)"
        let results = DBHelper.shared.fetchQuery(query)
        
        return results.compactMap {
            Product(
                id: $0["id"] as? Int ?? 0,
                name: $0["name"] as? String ?? "",
                description: $0["description"] as? String ?? "",
                category: $0["category"] as? String ?? "",
                price: $0["price"] as? Double ?? 0.0,
                stock: $0["stock"] as? Int ?? 0,
                imagePath: $0["imagePath"] as? String ?? ""
            )
        }.first!
    }

    
    func updateStock(productId: Int, quantity: Int) {
        let query = """
        UPDATE Products SET stock = stock + \(quantity) WHERE id = \(productId);
        """
        DBHelper.shared.executeQuery(query)
        
    }
    
    // MARK: - Histories Operations
    func insertHistory(productId: Int, type: String, quantity: Int, date: Date) {
        let dateString = ISO8601DateFormatter().string(from: date)
        let query = """
        INSERT INTO Histories (productId, type, quantity, date)
        VALUES (\(productId), '\(type)', \(quantity), '\(dateString)');
        """
        DBHelper.shared.executeQuery(query)
        
        if type == "Masuk" {
            updateStock(productId: productId, quantity: quantity)
            
        } else {
            updateStock(productId: productId, quantity: -quantity)
        }
    }
    
    func fetchHistories(forProductId productId: Int) -> [History] {
        let query = "SELECT * FROM Histories WHERE productId = \(productId)"
        let results = DBHelper.shared.fetchQuery(query)
        
        let dateFormatter = ISO8601DateFormatter()
        
        return results.map { row in
            let id = row["id"] as? Int ?? 0
            let productId = row["productId"] as? Int ?? 0
            let type = row["type"] as? String ?? ""
            let quantity = row["quantity"] as? Int ?? 0
            
            let date: Date = {
                if let dateString = row["date"] as? String,
                   let parsedDate = dateFormatter.date(from: dateString) {
                    return parsedDate
                }
                return Date()
            }()
            
            return History(
                id: id,
                productId: "\(productId)", // Sesuaikan tipe data jika perlu
                type: type,
                quantity: quantity,
                date: date
            )
        }
    }
}
