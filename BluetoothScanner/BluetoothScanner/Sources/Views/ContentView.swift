//
//  ContentView.swift
//  BluetoothScanner
//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                BleList()
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
            .environmentObject(BluetoothViewModel())
    }
}
