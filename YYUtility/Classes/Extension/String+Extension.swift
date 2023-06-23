//
//  NSString+Extension.swift
//  YYUtility
//
//  Created by cary on 2023/6/21.
//

import Foundation

extension String {
    func utf8Data() -> Data? {
        return self.data(using: .utf8)
    }
    
    func uuid() -> String {
        return UUID().uuidString
    }
    
    func md5() -> String {
        let data = self.data(using: .utf8)!
        return (data as NSData).yy_md5String()
    }
}
