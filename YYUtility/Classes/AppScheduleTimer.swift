//
//  AppScheduleTimer.swift
//  Driver
//
//  Created by cary on 2022/6/17.
//  Copyright © 2022 Driver. All rights reserved.
//

import Foundation
import UIKit

class AppScheduleTimer {
    private var timer: DispatchSourceTimer?
    
    /// 执行timer
    /// - Parameters:
    ///   - seconds: 时间间隔：秒(s)
    ///   - repeats: 是否重复
    ///   - handler: 事件
    /// - Returns: AppScheduleTimer
    static func scheduleTimer(interval seconds: Double, repeats: Bool, handler: ((AppScheduleTimer) -> Void)?) -> AppScheduleTimer {
        let scheduleTimer = AppScheduleTimer.init()
        let repeatingSeconds = repeats ? seconds : 0
        scheduleTimer.startTimer(dealineSeconds: seconds, repeating: repeatingSeconds, handler: handler)
        return scheduleTimer
    }
    
    /// 执行timer
    /// - Parameters:
    ///   - dealine: 延迟时间：秒
    ///   - repeating: 重复时间（时间间隔）：秒
    ///   - handler: 事件
    /// - Returns: AppScheduleTimer
    static func scheduleTimer(dealineSeconds dealine: Double, repeating: Double, handler: ((AppScheduleTimer) -> Void)?) -> AppScheduleTimer {
        let scheduleTimer = AppScheduleTimer.init()
        scheduleTimer.startTimer(dealineSeconds: dealine, repeating: repeating, handler: handler)
        return scheduleTimer
    }
    
    /// 开启
    /// - Parameters:
    ///   - dealine: 延迟时间：秒
    ///   - repeating: 重复时间（时间间隔）：秒
    ///   - handler: 事件
    func startTimer(dealineSeconds dealine: Double, repeating: Double, handler: ((AppScheduleTimer) -> Void)?) {
        cancleTimer()
        
        let dealineTime = Int(dealine * Double(1e3))
        let repeatingTime = Int(repeating * Double(1e3))
        let leewayTime = 0
        
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer?.schedule(deadline: .now() + .milliseconds(dealineTime), repeating: DispatchTimeInterval.milliseconds(repeatingTime), leeway: DispatchTimeInterval.milliseconds(leewayTime))
        timer?.setEventHandler {
            if handler != nil {
                handler!(self)
            }
            if repeatingTime <= 0 {
                self.cancleTimer()
            }
        }
        timer?.resume()
    }
    
    /// 开始计时
    func resumeTimer() {
        timer?.resume()
    }
    
    /// 暂停计时
    func stopTimer() {
        timer?.suspend()
    }
    
    /// 取消计时
    func cancleTimer() {
        timer?.cancel()
        timer = nil
    }
    
    deinit {
        cancleTimer()
        print("AppScheduleTimer deinit")
    }
}
