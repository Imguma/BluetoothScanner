//
//  BluetoothSerial.swift
//  BluetoothTestNoStoryboard
//
//  Created by 애니모비 on 2022/12/08.
//

import Foundation
import UIKit
import CoreBluetooth

// 블루투스를 연결하는 과정에서의 시리얼과 뷰의 소통을 위해 필요한 프로토콜
protocol BluetoothSerialDelegate: AnyObject {
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber)
    func serialDidConnectPeripheral(peripheral: CBPeripheral)
    func serialDidDisconnectPeripheral(peripheral: CBPeripheral)
    func serialDidDiscoverServices(peripheral: CBPeripheral, services: [CBService]?)
    func serialdidDiscoverCharacteristics(peripheral: CBPeripheral, characteristics: [CBCharacteristic]?)
    func serialDidReceiveData(_ data: Data)
}

// 프로토콜에 포함되어 있는 일부 함수를 옵셔널로 설정
extension BluetoothSerialDelegate {
    func serialDidReceiveData(_ data: Data) {}
    func serialDidDiscoverServices(peripheral: CBPeripheral, services: [CBService]?) {}
    func serialdidDiscoverCharacteristics(peripheral: CBPeripheral, characteristics: [CBCharacteristic]?) {}
}

// 블루투스 통신을 담당할 시리얼을 클래스
// CoreBluetooth를 사용하기 위한 프로토콜을 추가해야함
class BluetoothSerial: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    // BluetoothSerialDelegate 프로토콜에 등록된 메서드를 수행하는 delegate
    var delegate : BluetoothSerialDelegate?
    
    // 블루투스 주변기기를 검색하고 연결하는 역할 수행
    var centralManager : CBCentralManager!

    // 현재 연결을 시도하고 있는 블루투스 주변기기를 의미
    var pendingPeripheral : CBPeripheral?
    
    var timerMananer = TimerObj.shared
    
    // 연결에 성공된 기기를 의미, 기기와 통신을 시작하게되면 이 객체 이용
    @Published var connectedPeripheral : CBPeripheral?
    
    // 데이터를 주변기기에 보내기 위한 characteristic을 저장하는 변수
    weak var writeCharacteristic: CBCharacteristic?
    
    // 데이터를 주변기기에 보내는 type 설정, withResponse는 데이터를 보내면 이에 대한 답장이 오는 경우입니다. withoutResponse는 반대로 데이터를 보내도 답장이 오지 않는 경우
    private var writeType: CBCharacteristicWriteType = .withResponse
    
    // Peripheral이 가지고 있는 서비스의 UUID, 거의 모든 HM-10모듈이 기본적으로 갖고있는 FFE0으로 설정. 하나의 기기는 여러개의 serviceUUID를 가질 수도 있음
//    var serviceUUID: CBUUID = CBUUID(string: "")
    
    // characteristicUUID는 serviceUUID에 포함되어있음, 이를 이용하여 데이터를 송수신합니다. FFE0 서비스가 갖고있는 FFE1로 설정하였습니다. 하나의 service는 여러개의 characteristicUUID를 가질 수 있음
//    var characteristicUUID: CBUUID = CBUUID(string: "")
    
    // 통신이 가능한 상태라면 true 반환
    var bluetoothIsReady:  Bool  {
        get {
            return centralManager.state == .poweredOn
        }
    }
    
    var handleData: ((String) -> Void)?
    
    //MARK: 함수
    // serial을 초기화할 떄 호출, 시리얼은 nil될 수 없기 때문에 항상 초기화후 사용해야함
//    init(serviceUUID: String, characteristicUUID: String) {
//        self.serviceUUID = CBUUID(string: serviceUUID)
//        self.characteristicUUID = CBUUID(string: characteristicUUID)
//        print("🌀Bluetooth init!")
//    }
    
    override init() {
        super.init()
    }
    
    deinit {
        print("🌀Bluetooth deinit!")
    }
    
    // 블루투스 사용 권한 요청
    func checkPermission() {
        print("[🌀BluetoothSerial > checkPermission() : 블루투스 사용 권한 요청 실시]")
        // options: ["CBCentralManagerOptionShowPowerAlertKey": 0] > (BLE일 경우에만 뜨는 새로운 연결 허용 alert) 비활성화 가능
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // 기기 검색 시작, 연결이 가능한 모든 주변기기를 serviceUUID를 통해 찾아냅니다.
    func startScan() {
        timerMananer.startTimer()
        guard centralManager.state == .poweredOn else { return }
        
        // CBCentralManager의 메서드인 scanForPeripherals를 호출하여 연결가능한 기기들을 검색
        // withService 파라미터에 nil을 입력하면 모든 종류의 기기가 검색되고, 지금과 같이 serviceUUID를 입력하면 특정 serviceUUID를 가진 기기만을 검색
        // 새로운 주변기기가 연결될 때마다 centralManager(_:didDiscover:advertisementData:rssi:)를 호출합니다.
        centralManager.scanForPeripherals(withServices: [], options: nil)
    }
    
    // 무게 측정시 호출
    func discoverServices() {
        // peripheral의 Service들을 검색, 파라미터를 nil으로 설정하면 peripheral의 모든 service를 검색
        connectedPeripheral?.discoverServices([])
    }
    
    // 기기 검색 중단
    func stopScan() {
        centralManager.stopScan()
        if timerMananer.timer != nil {
            timerMananer.stopTimer()
        }
    }
    
    // 파라미터로 넘어온 주변 기기를 CentralManager에 연결하도록 시도
    func connectToPeripheral(_ peripheral: CBPeripheral)
    {
        // 연결 실패를 대비하여 현재 연결 중인 주변 기기를 저장
        pendingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    // 파라미터로 넘어온 주변 기기의 연결을 끊도록 시도(인스턴스 해제)
    func disConnectToPeripheral(_ peripheral: CBPeripheral)
    {
        print("[🌀BluetoothSerial > cancelPeripheralConnection() : 장치 연결 해제")
        centralManager.cancelPeripheralConnection(peripheral)
//        centralManager = nil
//        delegate = nil
        connectedPeripheral = nil
        pendingPeripheral = nil
        writeCharacteristic = nil
    }
    
    // String 형식으로 데이터를 주변기기에 전송합니다.
    func sendMessageToDevice(_ message: String) {
        guard bluetoothIsReady else { return }
        // String을 utf8 형식의 데이터로 변환하여 전송합니다.
        if let data = message.data(using: String.Encoding.utf8) {
            connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
        }
    }
    
    // 데이터 Array를 Byte형식으로 주변기기에 전송합니다.
    func sendBytesToDevice(_ bytes: [UInt8]) {
        guard bluetoothIsReady else { return }
        
        let data = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
        connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
    }
    
    // 데이터를 주변기기에 전송합니다.
    func sendDataToDevice(_ data: Data) {
        guard bluetoothIsReady else { return }
        
        connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
    }
    
    //MARK: Central, Peripheral Delegate 함수
    // CBCentralManagerDelegate에 포함되어 있는 메서드. central 기기의 블루투스 상태가 변경될 때마다 호출. centralManager.state의 값은 켜져있을 때 .poweredOn, 꺼져있을 때 .poweredOff로 변경됨
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("[🌀central.state : unknown > 관리자의 상태와 앱의 Bluetooth 서비스 연결을 알 수 없음]")
            
        case .resetting:
            print("[🌀central.state : resetting > Bluetooth 서비스와의 연결이 중단됨]")
            
        case .unsupported:
            print("[🌀central.state : unsupported > 기기가 Bluetooth 지원하지 않음]")
            
        case .unauthorized:
            // 블루투스 앱 권한 거부 상태 > 권한 설정으로 이동하는 alert 활성화!
            print("[🌀central.state : unauthorized > 사용자가 블루투스 사용에 대한 앱 권한 거부, 앱 설정 메뉴에서 다시 활성화]")
            
        case .poweredOff:
            print("[🌀central.state : poweredOff > Bluetooth 꺼진 상태]")
            
        case .poweredOn:
            print("[🌀central.state : poweredOn > Bluetooth 켜진 상태]")
            startScan()
            
        @unknown default:
            print("[🌀central.state : default case]")
        }
    }
    
    // MARK: 기기가 검색될 때마다 호출되는 메서드
    /*-----------------------------------------------------------------
     - Parameters
     ➢ central: 장치를 발견한 중앙 관리자 객체
     ➢ peripheral: 발견된 주변 장치
     ➢ advertisementData: 광고된 패킷에 포함된 data 딕셔너리, CoreBluetooth는 기본 키세트를 사용하여 이 데이터를 분석하고 구성함
     ➢ RSSI: 수신된 광고 패킷의 신호 강도, -30 ~ -99 범위를 가지며 -30이 제일 강한 강도
     ----------------------------------------------------------------*/
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // RSSI는 기기의 신호 강도 의미
//        print("")
//        print(" > 블루투스 스캔 [UUID] : \(String(peripheral.identifier.uuidString))]")
//        print(" > 블루투스 스캔 [RSSI] : \(String(RSSI.intValue))]")
//        print(" > 블루투스 스캔 [NAME] : \(String(peripheral.name ?? ""))]")
//        print("")
        
        // 특정 이름를 찾은 경우 연결 시도
        //        if peripheral.name?.lowercased() == Bluetooth.BLUETOOTH_SERIAL_NAME {
        //            connectToPeripheral(peripheral)
        //        }
        
        if timerMananer.timer == nil {
            stopScan()
        }
        
        delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: RSSI)
    }
    
    
    // MARK: 기기가 연결되면 호출되는 메서드
    /*-----------------------------------------------------------------
     - Parameters
     ➢ central: 중앙관리자
     ➢ peripheral: 연결된 주변기기
     ----------------------------------------------------------------*/
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[🌀didConnect > 연결 성공]")   

        peripheral.delegate = self
        pendingPeripheral = nil
        connectedPeripheral = peripheral
        
        delegate?.serialDidConnectPeripheral(peripheral: peripheral)
    }
    
    // MARK: 연결이 실패했을 때 호출되는 메서드
    /*-----------------------------------------------------------------
     - Parameters
     ➢ central: 중앙관리자
     ➢ peripheral: 연결 시도하였으나 실패한 주변기기
     ➢ error: 실패 이유(에러)
     ----------------------------------------------------------------*/
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("🌀didFailToConnect > 연결 시도 실패]")
        print(" > 실패한 기기 [NAME] : \(String(peripheral.name ?? ""))]")
        
        if let error = error {
            print("error description: \(error.localizedDescription)")
            return
        }
    }
    
    // MARK: 연결이 끊기면 호출되는 메서드
    /*-----------------------------------------------------------------
     - Parameters
     ➢ central: 중앙 관리자
     ➢ peripheral: 연결 해제된 주변 장치
     ➢ error: 해제 실패시 오류 내용
     ----------------------------------------------------------------*/
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        print("[🌀didDisconnectPeripheral > 연결 끊김]")
        
        if let error = error {
            print("error description: \(error.localizedDescription)")
        }
        
        switch(peripheral.state){
        case .disconnected: break
            
        default: break
        }
    }
    
    // service 검색에 성공 시 호출되는 메서드
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("")
        print("[🌀didDiscoverServices > service 검색 성공]")
        if let error = error {
            print("error description: \(error.localizedDescription)")
            return
        }
        print("")

        guard let services = peripheral.services else { return }
        delegate?.serialDidDiscoverServices(peripheral: peripheral, services: services)
        
        for service in services {
            // 검색된 모든 service에 대해서 characteristic을 검색합니다. 파라미터를 nil로 설정하면 해당 service의 모든 characteristic을 검색합니다.
            peripheral.discoverCharacteristics([], for: service)
            print(String(describing: service))
            print(service.uuid)
        }
    }
    
    // characteristic 검색에 성공 시 호출되는 메서드
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("[🌀didDiscoverCharacteristicsFor > characteristic 검색 성공]")
        if let error = error {
            print("error description: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        delegate?.serialdidDiscoverCharacteristics(peripheral: peripheral, characteristics: characteristics)
        
        for characteristic in characteristics {
            // 검색된 모든 characteristic에 대해 characteristicUUID를 한번 더 체크하고, 일치한다면 peripheral을 구독하고 통신을 위한 설정을 완료합니다.
//            if characteristic.uuid == characteristicUUID {
//                // 해당 기기의 데이터를 구독
//                peripheral.setNotifyValue(true, for: characteristic)
//                // 데이터를 보내기 위한 characteristic을 저장
//                writeCharacteristic = characteristic
//                // 데이터를 보내는 타입을 설정, 이는 주변기기가 어떤 type으로 설정되어 있는지에 따라 변경됨
//                writeType = characteristic.properties.contains(.write) ? .withResponse :  .withoutResponse
//                // 주변 기기와 연결 완료 시 동작하는 코드를 여기에 작성
//                delegate?.serialDidConnectPeripheral(peripheral: peripheral)
//            }
            
        }
    }
    
    // peripheral으로부터 데이터를 전송받으면 호출되는 메서드입니다.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("[🌀didUpdateValueFor > 데이터 전송 받음]")
        if let error = error {
            print("error description: \(error.localizedDescription)")
            return
        }
        
        // 전송받은 데이터가 존재하는지 확인
        let data = characteristic.value
        guard data != nil else { return }
        
        handleData?(serialDidReceiveData(data: data))
        
        // 데이터 구독 취소 (실시간으로 데이터가 계속 들어오기 때문)
        peripheral.setNotifyValue(false, for: characteristic)
        return
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // print("updateNotification: \(characteristic.isNotifying)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // writeType이 .withResponse일 때, 블루투스 기기로부터의 응답이 왔을 때 호출되는 메서드
        // 필요한 로직 작성
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print(invalidatedServices)
    }
}

extension BluetoothSerial {
    func serialDidReceiveData(data: Data?) -> String {
        // 데이터를 String으로 변환하고, 변환된 값을 파라미터로 한 delegate함수를 호출
        if let dataToString = String(data: data!, encoding: String.Encoding.utf8) {
           
        }
        return ""
    }
}
