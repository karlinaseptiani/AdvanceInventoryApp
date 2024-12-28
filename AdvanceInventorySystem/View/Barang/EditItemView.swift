//
//  AddItemView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 28/12/24.
//


import SwiftUI
import UIKit
import FirebaseAuth

struct EditItemView: View {
    
    @StateObject private var viewModel = ItemViewModel()

    var item: Item

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

    @Environment(\.dismiss) var dismiss
    
    init(item: Item) {
        self.item = item
        _namaBarang = State(initialValue: item.name)
        _deskripsi = State(initialValue: item.description)
        _kategori = State(initialValue: item.category)
        _harga = State(initialValue: String(item.price))
        _stock = State(initialValue: String(item.stock))
    }

    
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
                
                Section(header: Text("Ganti Foto")) {
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
                      let stockValue = Int(stock) else {
                   
                    alertMessage = "Please fill in all fields correctly."
                    showAlert = true
                    return
                }


                var updatedItem = item
                updatedItem.name = namaBarang
                updatedItem.description = deskripsi
                updatedItem.category = kategori
                updatedItem.price = hargaValue
                updatedItem.stock = stockValue

                if let newImage = selectedImage,
                   let imageData = newImage.jpegData(compressionQuality: 0.5) {
                    await viewModel.editItem(for: item.supplierID, item: updatedItem, newImageData: imageData)
                } else {
                    await viewModel.editItem(for: item.supplierID, item: updatedItem, newImageData: nil)
                }

                dismiss()
            }
        }
    }

}


#Preview {
    AddItemView(supplierID: "", supplierName: "")
}
