//
//  BleDetail.swift
//  practice_ble
//
//  Created by 애니모비 on 2023/08/02.
//

import SwiftUI
import Lottie

struct BleDetail: View {
    @EnvironmentObject var bluetoothViewModel: ViewModel
    @Binding var isConnected: Bool
    @Binding var peripheral: Peripheral
    @State var isShowCharacteristicDetail: Bool = false
    
    var body: some View {
        ZStack {
            if !isConnected {
                Color.black
                    .opacity(0.35)
                    .ignoresSafeArea()
                    .zIndex(1)
                
                LottieView(name: "lottie_loading", loopMode: .loop, animationSpeed: 1)
                    .scaleEffect(0.15)
                    .zIndex(2)
            }
            
            VStack {
                List {
                    if isConnected {
                        if let services = peripheral.services {
                            ForEach(services, id: \.self) { service in
                                Section(header: Text("Service")) {
                                    Text("UUID: \(String(describing: service.uuid))")
                                        .font(.system(size: 13))
                                    if let characteristics = peripheral.characteristics {
                                        ForEach(characteristics, id: \.self) { characteristic in
                                            Button {
                                                isShowCharacteristicDetail.toggle()
                                            } label: {
                                                Text("UUID: \(String(describing: characteristic.uuid))")
                                                    .font(.system(size: 13))
                                            }
                                            if isShowCharacteristicDetail {
                                                Text("Properties: \(String(describing: characteristic.properties))")
                                                    .font(.system(size: 13))
                                                Text("Data: \(String(describing: characteristic.value))")
                                                    .font(.system(size: 13))
                                                Text("Desciptor: \(String(describing: characteristic.descriptors))")
                                                    .font(.system(size: 13))
                                                Text("IsBroadcasted: \(String(describing: characteristic.isBroadcasted))")
                                                    .font(.system(size: 13))
                                                Text("IsNotifying: \(String(describing:characteristic.isNotifying))")
                                                    .font(.system(size: 13))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("\(peripheral.name)")
            }
        }
        .onAppear {
            if bluetoothViewModel.centralIsScanning {
                bluetoothViewModel.stopScan()
            }
            bluetoothViewModel.connectToPeripheral(peripheral.peripheral)
        }
        .onDisappear {
            if isConnected {
                bluetoothViewModel.disConnectToPeripheral(peripheral.peripheral)
            }
        }
    }
}

//struct BleDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        BleDetail()
//    }
//}
