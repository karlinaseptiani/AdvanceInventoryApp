//
//  DBHelper.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 18/12/24.
//


import Foundation
import SQLite3

class DBHelper {
    static let shared = DBHelper()
    private let dbName = "BasicInventorySystem.sqlite"
    private var db: OpaquePointer?
    
    private init() {
        openDatabase()
    }
    
    func openDatabase() {
        guard let path = try? FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(dbName).path else {
            print("Failed to get database path")
            return
        }
        
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("Failed to open database")
        }
    }
    
    func executeQuery(_ query: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to execute query: \(query)")
            }
        } else {
            print("Error preparing query: \(query)")
        }
        sqlite3_finalize(statement)
    }
    
    func fetchQuery(_ query: String) -> [[String: Any]] {
        var results = [[String: Any]]()
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let columnCount = sqlite3_column_count(statement)
                var row = [String: Any]()
                
                for i in 0..<columnCount {
                    let name = String(cString: sqlite3_column_name(statement, i))
                    let type = sqlite3_column_type(statement, i)
                    
                    switch type {
                    case SQLITE_INTEGER:
                        row[name] = Int(sqlite3_column_int(statement, i))
                    case SQLITE_FLOAT:
                        row[name] = sqlite3_column_double(statement, i)
                    case SQLITE_TEXT:
                        if let text = sqlite3_column_text(statement, i) {
                            row[name] = String(cString: text)
                        }
                    default:
                        row[name] = nil
                    }
                }
                results.append(row)
            }
        } else {
            print("Error preparing query: \(query)")
        }
        
        sqlite3_finalize(statement)
        return results
    }
}


