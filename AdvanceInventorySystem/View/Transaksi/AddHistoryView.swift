//
//  AddHistoryView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 18/12/24.
//


import SwiftUI

struct AddHistoryView: View {
    @State private var jenis = "Masuk"
    @State private var jumlah = ""
    @State private var tanggal = Date()
    
    @Binding var isPresented: Bool

    @StateObject private var transactionViewModel = TransactionViewModel()
    
    var supplierID: String
    var itemID: String
    var itemName: String

    var body: some View {
        VStack {
            Form {
                Picker("Jenis Transaksi", selection: $jenis) {
                    Text("Masuk").tag("Masuk")
                    Text("Keluar").tag("Keluar")
                }
                TextField("Jumlah", text: $jumlah)
                    .keyboardType(.numberPad)
                DatePicker("Tanggal", selection: $tanggal, displayedComponents: .date)
            }

            Button(action: {
                let jumlahValue = Int(jumlah) ?? 0
                
                let transaction = Transaction(itemId: itemID, itemName: itemName, type: jenis, quantity: jenis == "Masuk" ? jumlahValue : -jumlahValue, date: tanggal, supplierID: supplierID)
                print("cek transaksi: \(transaction)")

                Task {
                    await transactionViewModel.addTransaction(idSupplier: supplierID, idItem: itemID, transaction: transaction)
                    isPresented = false
                }

            }) {
                Text("Simpan Transaksi")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Tambah Transaksi")
    }
}

#Preview {
    AddHistoryView(isPresented: .constant(true), supplierID: "", itemID: "", itemName: "Beras")
}
