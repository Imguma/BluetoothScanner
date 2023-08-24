//
//  BleDetail.swift
//  BluetoothScanner
//
//

import SwiftUI
import Lottie

struct BleDetail: View {
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel
    @Binding var peripheral: Peripheral
    
    @State var isShowCharacteristicDetail: Bool = false
    
    var body: some View {
        ZStack {
            if !bluetoothViewModel.isConnect {
                Color.black
                    .opacity(0.35)
                    .ignoresSafeArea()
                    .zIndex(1)
                
                LottieView(name: Bluetooth.BLUETOOTH_LOTTIE_NAME, loopMode: .loop, animationSpeed: 1)
                    .scaleEffect(0.15)
                    .zIndex(2)
            }
            
            VStack {
                List {
                    if bluetoothViewModel.isConnect {
                        if let services = peripheral.services {
                            ForEach(Array(services.keys), id: \.self) { service in
                                Section(header: Text("Service\nUUID: \(String(describing: service.uuid))")) {
                                    if let characteristics = services[service] {
                                        ForEach(characteristics, id: \.self) { characteristic in
                                            Text("Characteristic")
                                                .foregroundColor(Color.cyan)
                                            Text("UUID: \(String(describing: characteristic.uuid))")
                                                .font(.system(size: 13))
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
            if bluetoothViewModel.isConnect {
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
