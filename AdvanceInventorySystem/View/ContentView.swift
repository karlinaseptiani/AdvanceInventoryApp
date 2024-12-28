//
//  ContentView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 16/12/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var supplierViewModel = SupplierViewModel()
    @StateObject private var itemViewModel = ItemViewModel()
    @StateObject private var dashboardViewModel = DashboardViewModel()

    var body: some View {
        Group {
            if authViewModel.userSession != nil {
                TabView {

                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }
                        .environmentObject(dashboardViewModel)
                        .environmentObject(supplierViewModel)
                        .environmentObject(itemViewModel)


                    SupplierView()
                        .tabItem {
                            Image(systemName: "doc.text")
                            Text("Supplier")
                        }
                        .environmentObject(supplierViewModel)
                        .environmentObject(itemViewModel)

                    ItemListView()
                        .tabItem {
                            Image(systemName: "doc.text")
                            Text("Barang")
                        }
                        .environmentObject(itemViewModel)
                    
                    AccountView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Account")
                        }


                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
