//
//  BluetoothViewModel.swift
//  BluetoothScanner
//
//

import Foundation
import CoreBluetooth

final class BluetoothViewModel: ObservableObject {
    private var serial: BluetoothSerial
    @Published var peripheralList: [String: Peripheral] = [:]
    @Published var isConnect: Bool = false

    var centralIsScanning: Bool {
        get {
            return serial.centralManager.isScanning
        }
    }

    init(serial: BluetoothSerial = BluetoothSerial(timerMananer: TimerObj(timeOut: Bluetooth.BLUETOOTH_SCAN_TIME))) {
        self.serial = serial
        serial.delegate = self
    }

    func setTarget(target: Target) {
        guard let name = target.name else { return }
        guard let serviceUUID = target.serviceUUID else { return }
        guard let characteristicUUID = target.characteristicUUID else { return }
        
        serial.peripheralName = name
        serial.serviceUUID = CBUUID(string: serviceUUID)
        serial.characteristicUUID = CBUUID(string: characteristicUUID)
    }
    
    func checkPermission() {
        serial.checkPermission()
    }
    
    func startScan() {
        serial.startScan()
    }
    
    func stopScan() {
        serial.stopScan()
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        serial.connectToPeripheral(peripheral)
    }
    
    func disConnectToPeripheral(_ peripheral: CBPeripheral) {
        serial.disConnectToPeripheral(peripheral)
        isConnect = false
    }
}

extension BluetoothViewModel: BluetoothSerialDelegate {
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber) {
        let discoverdPeripheral = Peripheral(peripheral: peripheral, uuid: String(peripheral.identifier.uuidString), name: String(peripheral.name ?? "unknown device"), rssi: String(RSSI.intValue))

        peripheralList.updateValue(discoverdPeripheral, forKey: String(peripheral.identifier.uuidString))
        
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
    
    func serialDidDiscoverServices(peripheral: CBPeripheral, service: CBService?) {
        peripheralList[peripheral.identifier.uuidString]?.services = [:]
    }
    
    func serialdidDiscoverCharacteristics(peripheral: CBPeripheral, service: CBService?) {
        guard let unwrapService = service else { return }
        guard let unwrapCharacteristics = service?.characteristics else { return }
        
        peripheralList[peripheral.identifier.uuidString]?.services?.updateValue(unwrapCharacteristics, forKey: unwrapService)
    }
}
