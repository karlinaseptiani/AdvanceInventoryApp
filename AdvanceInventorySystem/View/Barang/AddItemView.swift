//
//  AddItemView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 18/12/24.
//


import SwiftUI
import UIKit
import FirebaseAuth

struct AddItemView: View {
    
    @StateObject private var viewModel = ItemViewModel()

    var supplierID: String
    var supplierName: String

    @State private var namaBarang = ""
    @State private var deskripsi = ""
    @State private var kategori = ""
    @State private var harga = ""
    @State private var stock = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    @State private var showAlert = false
    @State private var alertMessage = ""

    @Environment(\.presentationMode) var presentationMode
    
    // tampilan tambah barang
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Informasi Barang")) {
                    TextField("Nama Barang", text: $namaBarang)
                    TextField("Deskripsi", text: $deskripsi)
                    TextField("Kategori", text: $kategori)
                    TextField("Harga", text: $harga)
                        .keyboardType(.numberPad)
                    TextField("Stok", text: $stock)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button(action: {
                        imagePickerSourceType = .camera
                        isImagePickerPresented = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Ambil Foto")
                        }
                    }
                }
                
                
                Section {
                    Button(action: {
                        imagePickerSourceType = .photoLibrary
                        isImagePickerPresented = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Pilih dari Galeri")
                        }
                    }
                }

                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(10)
                }

            }
            
            // button simpan

            Button(action: {
                saveProduct()
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
        .navigationTitle("Tambah Barang")
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage, sourceType: imagePickerSourceType)
        }
    }

    // MARK: - Helper Methods
    private func saveProduct() {
        Task {
            do {
                guard !namaBarang.isEmpty,
                      !deskripsi.isEmpty,
                      !kategori.isEmpty,
                      let hargaValue = Double(harga), // Parsing as Double
                      let stockValue = Int(stock),
                      let image = selectedImage,
                      let imageData = image.jpegData(compressionQuality: 0.5) else {
                   
                    alertMessage = "Please fill in all fields correctly."
                    showAlert = true
                    return
                }


                guard let userID = Auth.auth().currentUser?.uid else {
                    alertMessage = "UserID not found"
                    showAlert = true
                    return
                }

                let newItem = Item(name: namaBarang, description: deskripsi, category: kategori, price: hargaValue, stock: stockValue, supplierID: supplierID, supplierName: supplierName, userID: userID)
                await viewModel.addItem(to: supplierID, item: newItem, imageData: imageData)

                presentationMode.wrappedValue.dismiss()
            }
        }
    }

}


#Preview {
    AddItemView(supplierID: "", supplierName: "")
}
