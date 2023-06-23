//
//  YYAlertManager.swift
//  YYAlertManager
//
//  Created by cary on 2023/5/26.
//

import UIKit
import Foundation

@objc public enum YYAlertState: Int {
case waiting = 0, `default` = 1, showing = 2, showned = 3
}

public typealias YYAlertPriority = Int
public typealias YYAlertOperationBlock = (YYAlertManager, YYAlertStack) -> Void

public class YYAlertStack: NSObject {
    
    @objc public var object: AnyObject?
    
    let operationBlock: YYAlertOperationBlock
    var priority: YYAlertPriority = 0
    @objc public var state: YYAlertState = .default {
        didSet {
            if state != .waiting {
                self.stopWaiting()
            }
        }
    }
    fileprivate var timeoutInterval: Double = 5
    private var scheduleTimer: AppScheduleTimer?
    
    init(operation: @escaping YYAlertOperationBlock) {
        self.operationBlock = operation
        super.init()
    }
    
    init(operation: @escaping YYAlertOperationBlock, priority: YYAlertPriority) {
        self.operationBlock = operation
        self.priority = priority
        super.init()
    }
    
    init(operation: @escaping YYAlertOperationBlock, priority: YYAlertPriority, state: YYAlertState) {
        self.operationBlock = operation
        self.priority = priority
        self.state = state
        super.init()
    }
    
    func startWaiting(_ timeout: (() -> Void)?) {
        if timeoutInterval <= 0 {
            return
        }
        if self.state != .waiting {
            return
        }
        if self.scheduleTimer != nil {
            return
        }
        
        scheduleTimer = AppScheduleTimer.scheduleTimer(interval: self.timeoutInterval, repeats: false, handler: { timer in
            timer.cancleTimer()
            timeout?()
        })
    }
    
    func stopWaiting() {
        if let scheduleTimer = self.scheduleTimer {
            scheduleTimer.cancleTimer()
        }
        scheduleTimer = nil
    }
    
    deinit {
        stopWaiting()
    }
}

public class YYAlertManager: NSObject {
    @objc public static let manager = YYAlertManager()
    
    var stacks = [YYAlertStack]()
    var currentStack: YYAlertStack?
    @objc public var suspend = false
    
    /// 默认按照priovity大小排序，设置了此属性则按照给定的优先级排序
    @objc public var prioritys: [Int]?
    
    @objc public func addStack(_ stack: YYAlertStack) {
        synchronized(self) {
            stacks.append(stack)
        }
    }
    
    @objc public func addOperation(_ operation: @escaping YYAlertOperationBlock) -> YYAlertStack {
        return addOperation(operation, priority: 0, state: .default, timeoutInterval: 5)
    }
    
    @objc public func addOperation(_ operation: @escaping YYAlertOperationBlock, priority: YYAlertPriority) -> YYAlertStack {
        return addOperation(operation, priority: priority, state: .default, timeoutInterval: 5)
    }
    
    @objc public func addOperation(_ operation: @escaping YYAlertOperationBlock, priority: YYAlertPriority, state: YYAlertState, timeoutInterval: Double) -> YYAlertStack {
        let stack = YYAlertStack(operation: operation, priority: priority, state: state)
        stack.timeoutInterval = timeoutInterval
        addStack(stack)
        return stack
    }
    
    func nextStack() -> YYAlertStack? {
        if stacks.count == 0 {
            return nil
        }
        
        var stack: YYAlertStack? = nil
        synchronized(self) {
            if stacks.count == 1 {
                stack = stacks.popLast()
            } else {
                if let prioritys = self.prioritys {
                    stacks.sort { (s1, s2) in
                        let index1 = prioritys.firstIndex(of: s1.priority) ?? 0
                        let index2 = prioritys.firstIndex(of: s2.priority) ?? 0
                        return index1 > index2
                    }
                } else {
                    stacks.sort { $0.priority < $1.priority }
                }
                stack = stacks.popLast()
            }
        }
        return stack
    }
    
    @objc public func show() {
        if Thread.isMainThread == false {
            self.performSelector(onMainThread: #selector(show), with: nil, waitUntilDone: false)
            return
        }
        
        if suspend {
            return
        }
        
        if let currentStack = self.currentStack {
            if currentStack.state == .showing {
                return
            }
            if currentStack.state == .showned {
                hideAndShowNext(true)
                return
            }
        }
        
        guard let currentStack = self.currentStack ?? nextStack() else { return }
        self.currentStack = currentStack
        
        if currentStack.state == .waiting {
            currentStack.startWaiting {
                self.hideAndShowNext(false)
            }
            return
        }
        
        currentStack.state = .showing
        currentStack.operationBlock(self, currentStack)
    }
    
    @objc public func hide() {
        hideAndShowNext(false)
    }
    
    @objc public func hideAndShowNext(_ next: Bool) {
        self.currentStack?.stopWaiting()
        self.currentStack?.state = .showned
        self.currentStack = nil
        if next {
            show()
        }
    }
    
    @objc public func destory() {
        suspend = true
        hideAndShowNext(false)
    }
    
    private func synchronized(_ lock: Any, closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}

extension UIViewController {
//    @objc public let yy_alertManager: YYAlertManager
    // MARK: - AssociatedKeys
    private struct AssociatedKeys {
        static var AlertManagerKey = "AlertManagerKey"
    }
    
    @objc public var yy_alertManager: YYAlertManager {
        get {
            guard let alertManager = objc_getAssociatedObject(self, &AssociatedKeys.AlertManagerKey) as? YYAlertManager else {
                let alertManager = YYAlertManager()
                objc_setAssociatedObject(self, &AssociatedKeys.AlertManagerKey, alertManager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return alertManager
            }
            return alertManager
        }
    }
}
