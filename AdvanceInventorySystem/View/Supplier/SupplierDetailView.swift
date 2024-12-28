//
//  SupplierDetailView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 18/12/24.
//

import SwiftUI
import MapKit

struct SupplierDetailView: View {
    
    @Binding var supplier: Supplier
    
    @ObservedObject var itemViewModel = ItemViewModel()
    @State private var region: MKCoordinateRegion // region untuk menampung koordinat mapview supplier
    @EnvironmentObject var supplierViewModel: SupplierViewModel

    @Environment(\.dismiss) var dismiss

    // untuk inisiasi properti dari supploier dan region untuk lokasi supplier
    init(supplier: Binding<Supplier>) {
        self._supplier = supplier
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: supplier.wrappedValue.latitude, longitude: supplier.wrappedValue.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    
    // tampilan untuk detail supplier

    var body: some View {
        ScrollView{
            VStack{
                
                Text ("Supplier Detail")
                    .font(.title)
                    .bold()
                
                HStack{
                    VStack(alignment: .leading){
                        Text ("Nama Supplier : \(supplier.name)")
                        Text ("Alamat : \(supplier.address)")
                        Text ("Kontak : \(supplier.contact)")
                        Text ("Latitude : \(supplier.latitude) ||| Longitude : \(supplier.longitude)")
                    }
                    
                    Spacer()
                }
                
                Map(coordinateRegion: $region, annotationItems: [supplier]) { location in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                }
                .frame(height: 200)
                .cornerRadius(10)
                .shadow(radius: 5)
                .disabled(true)


                HStack{
                    Button {
                        openGoogleMaps(lat: supplier.latitude, lng: supplier.longitude)
                    } label: {
                        Text("Buka Maps")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .bold()
                            .background {
                                RoundedRectangle(
                                    cornerRadius: 50,
                                    style: .continuous
                                ).fill(.green)
                            }
                        
                    }

                    NavigationLink(destination: EditSupplierView(supplier: supplier).onDisappear(perform: {
                        itemViewModel.fetchItems(for: supplier.id ?? "")
                        print("cek data supplier: \(supplier.name)")
                    }))
                    {
                        Text("Edit Supplier")
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
                            await supplierViewModel.deleteSupplier(supplierID: supplier.id ?? "")
                            dismiss()
                        }
                    } label: {
                        Text("Hapus Supplier")
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

                
                Divider()
                
                NavigationLink(destination: AddItemView(supplierID: supplier.id ?? "", supplierName: supplier.name)) {
                    Text("Tambah Barang +")
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
                
                Text("Daftar Barang")
                
                // tampilkan list items
                if itemViewModel.items.isEmpty {
                    Text("Belum ada item")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(itemViewModel.items) { item in
                        NavigationLink(destination: ItemDetailView(item: item)){
                                   HStack(alignment: .top, spacing: 16) {
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
                                       
                                       // Informasi Item
                                       VStack(alignment: .leading, spacing: 8) {
                                           Text(item.name)
                                               .font(.headline)
                                               .lineLimit(1)
                                           
                                           Text("harga: Rp.\(item.price, specifier: "%.2f")")
                                               .font(.subheadline)
                                               .foregroundColor(.secondary)
                                           
                                           Text("stok: \(item.stock)")
                                               .font(.subheadline)
                                               .foregroundColor(.secondary)
                                           
                                           Text("kategori: \(item.category)")
                                               .font(.subheadline)
                                               .foregroundColor(.secondary)
                                           
                                       }
                                       
                                       Spacer()
                                   }
                                   .padding(.vertical, 8)
                               }
                           }
                }

                Spacer()


            }
            .hideTabBar()
            .onAppear {
                itemViewModel.fetchItems(for: supplier.id ?? "")
            }
            .padding()
            .onChange(of: supplier) { newSupplier in
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: newSupplier.latitude, longitude: newSupplier.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                
            }

        }
    }
    
    // fungsi untuk membuka googlemaps
    
    func openGoogleMaps(lat: Double, lng: Double) {
        let urlString = "http://maps.google.com/?q=\(lat),\(lng)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

}

