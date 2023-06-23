//
//  DataFetchManager.swift
//  Driver
//
//  Created by cary on 2022/6/27.
//  Copyright © 2022 Driver. All rights reserved.
//

import Foundation

protocol DataFetchProtocol {
    func fetchData(operation asyncOperation: AsyncBlockOperation, _ block: ((_ complete: Bool) -> Void)!)
}

typealias AsyncCompleteBlock = (AsyncBlockOperation) -> Void

class AsyncBlockOperation: Operation {
    private var executionBlock: AsyncCompleteBlock?
    
    internal var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    internal var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    public override var isFinished: Bool {
        return _finished
    }
    
    internal override var isConcurrent: Bool {
        return true
    }
    
    static func operationWithBlock(block: @escaping AsyncCompleteBlock) -> AsyncBlockOperation {
        let operation = AsyncBlockOperation.init(block: block)
        return operation
    }
    
    init(block: @escaping AsyncCompleteBlock) {
        super.init()
        executionBlock = block
    }
    
    override func start() {
        synchronized (self) {
            if self.isCancelled {
                self._finished = true
                return
            }
            
            self._finished = false
            self._executing = true
            
            if self.executionBlock != nil {
                self.executionBlock!(self)
            } else {
                self._executing = false
                self._finished = true
            }
        }
    }
    
    func complete() {
        synchronized (self) {
            if self.isExecuting {
                self._finished = true
                self._executing = false
            }
            self.executionBlock = nil
        }
    }
    
    override func cancel() {
        synchronized(self) {
            super.cancel()
            if self.isExecuting {
                self._executing = false
                self._finished = true
            }
            self.executionBlock = nil
        }
    }
    
    private func synchronized(_ lock: Any, closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}

class DataFetchManager {
    private var scheduleTimer: AppScheduleTimer?
    private let queue: OperationQueue!
    private let timeout: Double!
    
    private var _executing = false
    public var isExecuting: Bool {
        return _executing
    }
    
    init() {
        queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 10
        timeout = 3
    }
    
    init(timeout seconds: Double) {
        queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 10
        timeout = seconds
    }
    
    init(timeout seconds: Double, maxConcurrent operationCount: Int) {
        queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = operationCount
        timeout = seconds
    }
    
    func fetchData(datas: [AnyObject], completeBlock: ((_ complete: Bool) -> Void)?) {
        cancelAllFetched()
        
        var operations: [Operation] = []
        for model in datas {
            if let model = model as? DataFetchProtocol {
                let op = AsyncBlockOperation.init { asyncOperation in
                    model.fetchData(operation: asyncOperation) { [weak self] complete in
                        asyncOperation.complete()
                        
                        DispatchQueue.main.async {
                            if let self = self {
                                if self.queue.operationCount <= 0 {
                                    self.cancelAllFetched()
                                    completeBlock?(true)
                                }
                            }
                        }
                    }
                }
                operations.append(op)
            }
        }
        
        if operations.count == 0 {
            completeBlock?(true)
        } else {
            _executing = true
            queue.addOperations(operations, waitUntilFinished: false)
            scheduleTimer = AppScheduleTimer.scheduleTimer(interval: self.timeout, repeats: false) { [weak self] timer in
                self?.cancelAllFetched()
                completeBlock?(false)
            }
        }
    }
    func cancelAllFetched() {
        scheduleTimer?.cancleTimer()
        queue.cancelAllOperations()
        _executing = false
    }
    
    deinit {
        print("DataFetchManager deinit")
        cancelAllFetched()
    }
}
