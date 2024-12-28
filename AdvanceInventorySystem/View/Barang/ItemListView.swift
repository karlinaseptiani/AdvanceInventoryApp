//
//  ItemListView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 18/12/24.
//

import SwiftUI

struct ItemListView: View {
    
    @ObservedObject var itemViewModel = ItemViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        NavigationView {
            VStack {
                if !itemViewModel.items.isEmpty {
                    List(itemViewModel.items.filter { $0.userID == authViewModel.currentUser?.id }) { item in
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            HStack {
                            
                                if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .shadow(radius: 2)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 60, height: 60)
                                }
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                    .overlay(Text("No Image").font(.caption).foregroundColor(.gray))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.category)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(item.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                Text("Stok: \(item.stock)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("Supplier: \(item.supplierName)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                            }
                            Spacer()
                            
                            
                        }
                        .padding(.vertical, 8)
                    }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    
                    Spacer()
                    
                    Text("Belum ada barang tersimpan")
                    
                    Spacer()
                }
                                
            }
            .navigationTitle("Daftar Barang")
            .onAppear {
                itemViewModel.fetchItems()
            }
            .showTabBar()
        }
    }
}

#Preview {
    ItemListView()
}
