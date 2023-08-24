//
//  Target.swift
//  BluetoothScanner
//
//

import Foundation

struct Target {
    var name: String?
    var serviceUUID: String?
    var characteristicUUID: String?
    
    init(name: String = "", serviceUUID: String? = nil, characteristicUUID: String? = nil) {
        self.name = name
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
    }
}
