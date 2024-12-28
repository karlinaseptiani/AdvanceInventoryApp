//
//  AddSupplier.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 18/12/24.
//

import SwiftUI
import FirebaseAuth

struct AddSupplierView: View {
    
    @State private var name = ""
    @State private var address = ""
    @State private var contact = ""
    @State private var latitude = 0.0
    @State private var longitude = 0.0
    
    @State private var isShowingMapPicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @StateObject private var supplierViewModel = SupplierViewModel()
    
    // tampilan tambah supplier
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Form Input Data Supplier")) {
                    TextField("Nama Supplier", text: $name)
                    TextField("alamat", text: $address)
                    TextField("Kontak", text: $contact)
                    Text("Longitude: \(longitude) || Latitude \(latitude)")
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
                
                guard !name.isEmpty, !address.isEmpty, !contact.isEmpty, latitude != 0.0, longitude != 0.0 else {
                    alertMessage = "Please fill in all fields and select a location."
                    showAlert = true
                    return
                }
                
                guard let userID = Auth.auth().currentUser?.uid else {
                    alertMessage = "UserID not found"
                    showAlert = true
                    return
                }
                
                let newSupplier = Supplier(
                    id: UUID().uuidString,
                    userID: userID,
                    name: name,
                    address: address,
                    contact: contact,
                    longitude: longitude,
                    latitude: latitude
                )
                
                Task {
                    do {
                        await supplierViewModel.addSupplier(supplier: newSupplier)
                        alertMessage = "Supplier successfully saved!"
                        showAlert = true
                        
                        // untuk mengosongkan field
                        name = ""
                        address = ""
                        contact = ""
                        latitude = 0.0
                        longitude = 0.0
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
            MapPickerView(latitude: $latitude, longitude: $longitude, isPresented: $isShowingMapPicker)
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
