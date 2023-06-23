//
//  NSObject+Extension.swift
//  YYUtility
//
//  Created by cary on 2023/6/21.
//

import Foundation

extension NSObject {
    @objc public func jsonValid() -> Bool {
        return JSONSerialization.isValidJSONObject(self)
    }
    
    @objc public func toJsonData() -> Data? {
        if JSONSerialization.isValidJSONObject(self) {
            do {
                let data = try JSONSerialization.data(withJSONObject: self)
                return data
            } catch {
                return nil
            }
        }
        return nil
    }
    
    func toJsonString() -> String? {
        if let data = self.toJsonData() {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

extension Data {
    func jsonValueDecoded() -> Any? {
        do {
            let result = try JSONSerialization.jsonObject(with: self as Data)
            return result
        } catch {
            return nil
        }
    }
}

extension NSData {
    func jsonValueDecoded() -> Any? {
        return (self as Data).jsonValueDecoded()
    }
}
