//
//  AddSupplier.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 28/12/24.
//

import SwiftUI
import FirebaseAuth
import MapKit

struct EditSupplierView: View {

    
    @State var supplier: Supplier
    @State private var mapRegion: MKCoordinateRegion
    
    @State private var isShowingMapPicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @EnvironmentObject private var supplierViewModel : SupplierViewModel
    @Environment(\.dismiss) var dismiss
    
    init(supplier: Supplier) {
        self._supplier = State(initialValue: supplier)
        self._mapRegion = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: supplier.latitude, longitude: supplier.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    // tampilan tambah supplier
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Form Input Data Supplier")) {
                    TextField("Nama Supplier", text: $supplier.name)
                    TextField("alamat", text: $supplier.address)
                    TextField("Kontak", text: $supplier.contact)
                    Text("Longitude: \(supplier.longitude) || Latitude \(supplier.latitude)")
                }
                
                // button ambil lokasi
                Section {
                    Button(action: {
                        isShowingMapPicker = true
                    }) {
                        HStack {
                            Image(systemName: "location")
                            Text("Ambil lokasi")
                        }
                    }
                }
                
            }
            
            // button untuk menamnahkan supplier
            Button(action: {
                
                guard !supplier.name.isEmpty, !supplier.address.isEmpty, !supplier.contact.isEmpty, supplier.latitude != 0.0, supplier.longitude != 0.0 else {
                    alertMessage = "Please fill in all fields and select a location."
                    showAlert = true
                    return
                }
                
                
                Task {
                    do {
                        await supplierViewModel.updateSupplier(supplier: supplier)
                        mapRegion.center = CLLocationCoordinate2D(latitude: supplier.latitude, longitude: supplier.longitude)
                        dismiss()

                    } catch {
                        alertMessage = "Failed to update."
                        showAlert = true
                    }
                }

            }) {
                Text("Simpan")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $isShowingMapPicker) {
            MapPickerView(latitude: $supplier.latitude, longitude: $supplier.longitude, isPresented: $isShowingMapPicker)
        }
        .onChange(of: supplier.latitude) { newValue in
            mapRegion.center.latitude = newValue
        }
        .onChange(of: supplier.longitude) { newValue in
            mapRegion.center.longitude = newValue
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Supplier Tersimpan"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .hideTabBar()
        .navigationTitle("Tambah Supplier")
    }
    
}


#Preview {
    AddSupplierView()
}
