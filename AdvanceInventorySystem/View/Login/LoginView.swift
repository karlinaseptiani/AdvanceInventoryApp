//
//  LoginView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 18/12/24.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""

    @EnvironmentObject var viewModel: AuthenticationViewModel

    @State private var isShowRegister = false
    
    var body: some View {
        VStack(spacing: 16){
            Text("Login")
                .font(.title)
                .bold()
            
            Text("Silahkan Login ke Akun Anda!")
                .font(.body)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Text("Belum Punya Akun? ")
                
                Button {
                    isShowRegister = true
                } label: {
                    Text("Register")
                }

            }
            
            Spacer()
            
            Button {
                Task {
                    if !email.isEmpty && !password.isEmpty {
                        try await viewModel.login(email: email, password: password)
                    }

                }
            } label: {
                Text("Login")
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
        .fullScreenCover(isPresented: $isShowRegister) {
            RegisterView()
        }
        
    }
}

#Preview {
    LoginView()
}
