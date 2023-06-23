//
//  RSASignautre.swift
//  YYUtility
//
//  Created by cary on 2023/5/24.
//

import Foundation
import Security
import CommonCrypto

public class RSASignature: NSObject {
    @objc public static func signData(_ data: Data, privateKey: SecKey) -> NSData? {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digest.withUnsafeMutableBytes { (digestBytes) in
            data.withUnsafeBytes { (stringBytes) in
                CC_SHA256(stringBytes, CC_LONG(data.count), digestBytes)
            }
        }

        let signedData: NSMutableData = NSMutableData(length: SecKeyGetBlockSize(privateKey))!
        var signedDataLength: Int = signedData.length

        let err: OSStatus = SecKeyRawSign(
            privateKey,
            SecPadding.PKCS1SHA256,
            [UInt8](digest),
            digest.count,
            signedData.mutableBytes.assumingMemoryBound(to: UInt8.self),
            &signedDataLength
        )
        switch err {
            case noErr:
                return signedData
            default:
                return nil
        }
    }
    
    @objc public static func verifyData(_ data: Data, signature: NSData, publicKey: SecKey) -> Bool {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digest.withUnsafeMutableBytes { (digestBytes) in
            data.withUnsafeBytes { (stringBytes) in
                CC_SHA256(stringBytes, CC_LONG(data.count), digestBytes)
            }
        }

        let mutdata = NSMutableData(data: signature as Data)

        let err: OSStatus = SecKeyRawVerify(
            publicKey,
            SecPadding.PKCS1SHA256,
            [UInt8](digest),
            digest.count,
            mutdata.mutableBytes.assumingMemoryBound(to: UInt8.self),
            signature.length
        )
        switch err {
        case noErr:
            return true
        default:
            return false
        }
    }
}
