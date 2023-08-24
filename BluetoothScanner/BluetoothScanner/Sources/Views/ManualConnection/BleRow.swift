//
//  BlueRow.swift
//  BluetoothScanner
//
//

import SwiftUI

struct BleRow: View {
    @Binding var peripheral: Peripheral
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .center, spacing: 1) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                Text("\(peripheral.rssi)")
                    .font(.system(size: 10))
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text("\(peripheral.name)")
                    .fontWeight(.medium)
                Text("uuid: \(peripheral.uuid)")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
    }
}

//struct BleRow_Previews: PreviewProvider {
//    static var previews: some View {
//        BleRow(peripheral: ModelD)
//    }
//}
