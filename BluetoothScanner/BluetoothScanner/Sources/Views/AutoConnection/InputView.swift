//
//  InputView.swift
//  BluetoothScanner
//
//

// TODO: 수기로 기기 이름 입력하면 연결 진행 > 연결 되면 UUID 지정해서 데이터 가져오기
import SwiftUI

struct InputView: View {
    @State var name: String = ""
    @State var serviceUUID: String = ""
    @State var characteristicUUID: String = ""
    
    var body: some View {
        VStack(alignment:.leading, spacing: 15) {
            Text("기기 명")
            TextField("", text: $name)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
            Text("Service UUID")
            TextField("", text: $serviceUUID)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
            Text("Characteristic UUID")
            TextField("", text: $characteristicUUID)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            Spacer().frame(height: 20)
            Button {
                
            } label: {
                Text("연결")
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundColor(Color.white)
                    .background(Color.cyan)
                    .cornerRadius(5)
            }
        }
        .padding()
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
    }
}
