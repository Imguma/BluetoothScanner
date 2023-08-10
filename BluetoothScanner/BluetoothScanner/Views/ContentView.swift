//
//  ContentView.swift
//  practice_ble
//
//  Created by 애니모비 on 2023/07/31.
//

import SwiftUI

struct ContentView: View {
    @StateObject var bluetoothViewModel = ViewModel()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
//            VStack {
//                Spacer().frame(height: 90)
//                Button {
//
//                } label: {
//                    Text("재검색")
//                }
//            }
//            .padding()
//            .zIndex(1)
            
            VStack {
                BleList()
                    .environmentObject(bluetoothViewModel)
                Spacer()
            }
        }
        .onAppear {
            bluetoothViewModel.checkPermission()
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}
