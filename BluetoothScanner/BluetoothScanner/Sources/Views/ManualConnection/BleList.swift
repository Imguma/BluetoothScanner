//
//  BleList.swift
//  BluetoothScanner
//
//

import SwiftUI

struct BleList: View {
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bluetoothViewModel.peripheralList.keys.sorted(), id: \.self) { key in
                    if let element = $bluetoothViewModel.peripheralList[key] {
                        NavigationLink {
                            BleDetail(peripheral: element.unwrap()!)
                        } label: {
                            BleRow(peripheral: element.unwrap()!)
                        }
                    }
                }
            }
            .refreshable {
                bluetoothViewModel.startScan()
            }
            .navigationTitle("기기 목록")
        }
    }
}

//struct BleList_Previews: PreviewProvider {
//    static var previews: some View {
//        BleList(peripheralViewModel: <#Binding<ViewModel>#>)
//    }
//}
