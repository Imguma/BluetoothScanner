//
//  Peripheral.swift
//  BluetoothScanner
//
//

import Foundation
import CoreBluetooth

struct Peripheral: Identifiable {
    var id = UUID()
    var peripheral: CBPeripheral
    var uuid: String
    var name: String
    var rssi: String
    var services: [CBService: [CBCharacteristic]]?
}
