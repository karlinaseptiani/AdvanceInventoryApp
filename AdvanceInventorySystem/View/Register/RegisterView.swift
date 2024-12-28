//
//  RegisterView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 16/12/24.
//

import SwiftUI

struct RegisterView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmationpassword = ""
    
    
    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        VStack (spacing: 16){
            Text("Register")
                .font(.title)
                .bold()
            
            Text("Buat akun anda terlebih dahulu!")
                .font(.body)
            
            TextField("Nama", text: $name)
                .textFieldStyle(.roundedBorder)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            SecureField("Konfirmasi Password", text: $confirmationpassword)
                .textFieldStyle(.roundedBorder)


            HStack {
                Text("Sudah Punya Akun? ")
                
                Button {
                    dismiss()
                } label: {
                    Text("Login")
                }

            }
            
            
            Spacer()
            
            Button {
                Task {
                    if !name.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmationpassword {
                        try await viewModel.register(email: email, password: password, fullname: name)
                    } else {
                        print("lengkapi semua data")
                    }

                }
            } label: {
                Text("Register")
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

        }
        .padding()
    }
}

#Preview {
    RegisterView()
}
