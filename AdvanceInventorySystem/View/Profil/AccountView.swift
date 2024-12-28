//
//  AccountView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 23/12/24.
//


import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        
        if let user = viewModel.currentUser {
            NavigationView {
                VStack (spacing: 16) {

                    Text(user.fullname)
                        .font(.headline)
                    Text(user.email)
                        .font(.subheadline)
                    
                    
                    Button {
                        
                        viewModel.logout()
                        
                    } label: {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 50,
                                    style: .continuous
                                )
                                .fill(.yellow)
                            )
                    }

                }
                .padding()
                .navigationTitle("Account")
                .showTabBar()
            }

        }
    }
}

#Preview {
    AccountView()
}
