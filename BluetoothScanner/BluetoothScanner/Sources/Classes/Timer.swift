//
//  Timer.swift
//  BluetoothScanner
//
//

import Foundation
import UIKit

class TimerObj {
    var timer: Timer?
    var timeOut: Int
    var timerCount: Int = 1
    
    init(timeOut: Int) {
        self.timeOut = timeOut
    }
    
    deinit {
        print("timer deinit")
    }
    
    // 타이머 시작
    func startTimer() {
        print("⏰[startTimer : start] ")
        guard timer == nil else { return }

        // MARK: 타이머 객체 생성
        /*-----------------------------------------------------------------
         - Parameters
         ➢ timeInterval: 반복 주기 시간 설정
         ➢ target: 현재 클래스
         ➢ selector: 반복 작업 수행 함수
         ➢ userInfo: 타이머 속 함수에 값 전달
         ➢ repeats: 반복 여부 설정
         ----------------------------------------------------------------*/
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
    }
    
    // 실시간 반복 작업 수행 부분
    @objc func timerCallback() {
        print(" > timerCount : \(timerCount)")
        
        // timerCount 증가시키기
        timerCount += 1
        
        // timerCount에 따른 처리
        if timerCount > timeOut {
            // 타이머 종료
            stopTimer()
        }
    }
    
    // 실시간 반복 작업 정지 호출
    func stopTimer() {
        print("⏰[stopTimer : end]")
        
        // 실시간 반복 작업 중지
        timer?.invalidate()
        timer = nil
        timerCount = 1
    }
}
