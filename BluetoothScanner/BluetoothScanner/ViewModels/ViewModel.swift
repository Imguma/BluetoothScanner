//
//  Model.swift
//  practice_ble
//
//  Created by 애니모비 on 2023/08/02.
//

import Foundation
import CoreBluetooth

final class ViewModel: ObservableObject, BluetoothSerialDelegate {
    private var serial: BluetoothSerial
    @Published var peripheralList: [String: Peripheral] = [:]
//    var newPeripheralList: [String: Peripheral] = [:]
    @Published var isConnect: Bool = false

    var centralIsScanning: Bool {
        get {
            return serial.centralManager.isScanning
        }
    }
    
    init(serial: BluetoothSerial = BluetoothSerial()) {
        self.serial = serial
        serial.delegate = self
    }

    func checkPermission() {
        serial.checkPermission()
    }
    
    func startScan() {
        serial.startScan()
//        newPeripheralList = [:]
    }
    
    func stopScan() {
        serial.stopScan()
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        serial.connectToPeripheral(peripheral)
    }
    
    func disConnectToPeripheral(_ peripheral: CBPeripheral) {
        serial.disConnectToPeripheral(peripheral)
    }
    
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber) {
        let discoverdPeripheral = Peripheral(peripheral: peripheral, uuid: String(peripheral.identifier.uuidString), name: String(peripheral.name ?? "unknown device"), rssi: String(RSSI.intValue))

        let upsert = peripheralList.updateValue(discoverdPeripheral, forKey: String(peripheral.identifier.uuidString))
        
        // 새로운 값이 추가되면 nil 반환, 기존 값 update의 경우 optional 리턴
//        if upsert == nil {
//            newPeripheralList.updateValue(discoverdPeripheral, forKey: peripheral.identifier.uuidString)
//        }
        
        peripheralList
            .filter {
                $0.key == peripheral.identifier.uuidString
            }
            .keys
            .forEach {
                peripheralList[$0]?.peripheral = peripheral
            }
    
    }
    
    func serialDidConnectPeripheral(peripheral: CBPeripheral) {
        isConnect = true
        serial.discoverServices()
    }
    
    func serialDidDisconnectPeripheral(peripheral: CBPeripheral) {
        
    }
    
    func serialDidDiscoverServices(peripheral: CBPeripheral, services: [CBService]?) {
        peripheralList[peripheral.identifier.uuidString]?.services = services
    }
    
    func serialdidDiscoverCharacteristics(peripheral: CBPeripheral, characteristics: [CBCharacteristic]?) {
        peripheralList[peripheral.identifier.uuidString]?.characteristics = characteristics
    }
}
