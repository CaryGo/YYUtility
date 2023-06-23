//
//  NSData+YYCommonCryptor.h
//  YYUtility
//
//  Created by cary on 2023/6/23.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (YYCommonCryptor)

/// md2
- (NSString *)yy_md2String;

/// md4
- (NSString *)yy_md4String;

/// md5
- (NSString *)yy_md5String;

/// sha224
- (NSString *)yy_sha224String;

/// sha256
- (NSString *)yy_sha256String;

/// sha384
- (NSString *)yy_sha384String;

/// sha512
- (NSString *)yy_sha512String;

/// crc32
- (NSString *)yy_crc32String;

/// utf8编码
- (NSString *)yy_utf8String;

/// hex编码
- (NSString *)yy_hexString;

/// 从hex编码恢复
+ (NSData *)yy_dataWithHexString:(NSString *)hexStr;

/// base64编码
- (NSString *)yy_base64EncodedString;

/// 从base64编码恢复
+ (NSData *)yy_dataWithBase64EncodedString:(NSString *)base64EncodedString;

/// AES加密
/// - Parameters:
///   - key: 秘钥
///   - iv: 向量
- (NSData *)yy_aes256EncryptWithKey:(NSString *)key
                                 iv:(NSString *)iv;

/// AES解密
/// - Parameters:
///   - key: 秘钥
///   - iv: 向量
- (NSData *)yy_aes256DecryptWithkey:(NSString *)key
                                 iv:(NSString *)iv;

/// 3DES加密
/// - Parameters:
///   - key: 秘钥
///   - iv: 向量
- (NSData *)yy_3DESEncryptWithKey:(NSString *)key
                               iv:(NSString *)iv;

/// 3DES解密
/// - Parameters:
///   - key: 秘钥
///   - iv: 向量
- (NSData *)yy_3DESDecryptWithkey:(NSString *)key
                               iv:(NSString *)iv;

/// gzip压缩
- (NSData *)yy_gzipCompress;

/// gzip解压
- (NSData *)yy_gzipDecompress;

@end


@interface NSData (YYLowLevelCommonCryptor)

- (NSData *)yy_dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
                                       key: (id) key        // data or string
                      initializationVector: (id) iv        // data or string
                                   options: (CCOptions) options
                                     error: (CCCryptorStatus *) error;

- (NSData *)yy_decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
                                       key: (id) key        // data or string
                      initializationVector: (id) iv        // data or string
                                   options: (CCOptions) options
                                     error: (CCCryptorStatus *) error;

@end
