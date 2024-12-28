//
//  ItemDetailView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 18/12/24.
//


import SwiftUI

struct ItemDetailView: View {

    @State private var showingAddTransactionView = false
    @StateObject private var transactionViewModel = TransactionViewModel()

    @EnvironmentObject var itemViewModel: ItemViewModel
    @Environment(\.presentationMode) var presentationMode

    var item: Item

    var body: some View {
        VStack{
            ScrollView {
                VStack {
                    VStack(alignment: .leading) {
                        if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 60, height: 60)
                            }
                        }

                        
                        Text(item.name)
                            .font(.largeTitle)
                            .bold()
                        Text(item.description)
                            .font(.body)
                            .foregroundColor(.gray)
                        Text(item.category)
                            .font(.body)
                            .foregroundColor(.gray)
                        HStack {
                            Text("Harga: Rp \(item.price, specifier: "%.2f")")
                            Spacer()
                            Text("Stok: \(item.stock)")
                        }
                        .font(.headline)
                        .padding(.vertical)
                        
                    }
                    .padding()

                    
                    HStack {

                        NavigationLink(destination: EditItemView(item: item)) {
                            Text("Edit Barang")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .bold()
                                .background {
                                    RoundedRectangle(
                                        cornerRadius: 50,
                                        style: .continuous
                                    ).fill(.brown)
                                }
    
                        }
                        Button {
                            Task {
                                await itemViewModel.deleteItem(from: item.supplierID, imageURL: item.imageURL, itemID: item.id ?? "")
                                presentationMode.wrappedValue.dismiss()
                            }

                        } label: {
                            Text("Hapus Barang")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .bold()
                                .background {
                                    RoundedRectangle(
                                        cornerRadius: 50,
                                        style: .continuous
                                    ).fill(.orange)
                                }

                        }


                    }
                    Button {
                        showingAddTransactionView = true
                    } label: {
                        Text("Tambah Transaksi +")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .bold()
                            .background {
                                RoundedRectangle(
                                    cornerRadius: 50,
                                    style: .continuous
                                ).fill(.yellow)
                            }
                    }

                    

                    Divider()

                    Text("Riwayat Barang")
                        .font(.headline)
                    
                    Spacer()
                    
                    if transactionViewModel.transactions.isEmpty {
                        Text("Belum ada transaksi.")
                            .foregroundColor(.gray)

                    } else {
                        ForEach(transactionViewModel.transactions) { transaction in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack (alignment: .center) {
                                    
                                    VStack{
                                        Text(transaction.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)

                                        Text(transaction.type)
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                        
                                    }

                                    Spacer()
                                    
                                    Text(transaction.type == "Masuk" ? "+\(transaction.quantity)" : "\(transaction.quantity)")
                                        .font(.title2)
                                        .foregroundColor(.black)


                                }
                                
                            }
                            Divider()
                        }
                        .padding()
                        .listStyle(PlainListStyle())

                    }
                }
                .padding()
                .navigationTitle("Detail Barang")
                .sheet(isPresented: $showingAddTransactionView, onDismiss: {
                    Task{
                        await transactionViewModel.fetchTransactions(idSupplier: item.supplierID, idItem: item.id ?? "")
                    }
                }) {
                    AddHistoryView(isPresented: $showingAddTransactionView, supplierID: item.supplierID, itemID: item.id ?? "", itemName: item.name)
                }
                .onAppear{
                    Task{
                        await transactionViewModel.fetchTransactions(idSupplier: item.supplierID, idItem: item.id ?? "")
                    }
                }
                .hideTabBar()

            }
        }
    }
}


//#Preview {
//    let sample = Product(id: 1, name: "-", description: "-", category: "-", price: 1, stock: 1, imagePath: "")
//    ItemDetailView(product: sample)
//}
