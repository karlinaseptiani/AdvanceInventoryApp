//
//  DashboardView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 27/12/24.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel

    @State private var showItemList = false
    @State private var showSupplierList = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {

                HStack{
                    Button(action: {
                        showItemList = true
                    }) {
                        VStack(alignment: .center) {
                            Text("\(dashboardViewModel.totalItems)")
                                .font(.largeTitle)
                                .bold()

                            Text("Total Barang")
                                .font(.headline)
                                .foregroundColor(.gray)

                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .sheet(isPresented: $showItemList) {
                        ItemListView()
                    }


                    Button(action: {
                        showSupplierList = true
                    }) {
                        VStack(alignment: .center) {

                            Text("\(dashboardViewModel.totalSuppliers)")
                                .font(.largeTitle)
                                .bold()

                            Text("Total Supplier")
                                .font(.headline)
                                .foregroundColor(.gray)

                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                }
                .sheet(isPresented: $showSupplierList) {
                    SupplierView()
                }

                Spacer()
            }
            .navigationTitle("Dashboard")
            .padding()
            .onAppear(perform: {
                Task {
                    await dashboardViewModel.fetchTotalItems()
                    await dashboardViewModel.fetchTotalSuppliers()
                }
            })
        }
    }
}

#Preview {
    DashboardView()
}
