//
//  Peripheral.swift
//  practice_ble
//
//  Created by 애니모비 on 2023/08/02.
//

import Foundation
import CoreBluetooth

struct Peripheral: Identifiable {
    var id = UUID()
    var peripheral: CBPeripheral
    var uuid: String
    var name: String
    var rssi: String
    var services: [CBService]?
    var characteristics: [CBCharacteristic]?
}
