//
//  RSACryptor.h
//  YYUtility
//
//  Created by cary on 2023/6/23.
//

#import <Foundation/Foundation.h>

/**
 参考链接：
 https://blog.csdn.net/lining1041204250/article/details/79259920
 https://blog.csdn.net/kangpengpeng1/article/details/80526314
 */

/**
 生成RSA公钥和私钥：
 一、使用openssl命令生成秘钥对
 1、生成模长为1024bit的私钥文件private_key.pem
 $ openssl genrsa -out private_key.pem 1024
 
 2、生成证书请求文件rsaCertReq.csr
 $ openssl req -new -key private_key.pem -out rsaCerReq.csr
 //注意：这一步会提示输入国家、省份、mail等信息，可以根据实际情况填写，或者全部不用填写，直接全部敲回车.(PS：注意还得设置密码即：私钥文件设置密码，在解密时，private_key.p12文件需要和这里设置的密码配合使用，因此需要牢记此密码)
 
 3、生成证书rsaCert.crt，并设置有效时间为10年
 $ openssl x509 -req -days 3650 -in rsaCerReq.csr -signkey private_key.pem -out rsaCert.crt
 
 4、生成供iOS使用的公钥文件public_key.der
 $ openssl x509 -outform der -in rsaCert.crt -out public_key.der
 
 5、生成供iOS使用的私钥文件private_key.p12
 $ openssl pkcs12 -export -out private_key.p12 -inkey private_key.pem -in rsaCert.crt
 //PS：这里需要输入上边私钥文件设置密码，和再次确认密码；然后敲回车，完毕！
 
 6、生成供Java使用的公钥rsa_public_key.pem
 $ openssl rsa -in private_key.pem -out rsa_public_key.pem -pubout
 
 7、生成供Java使用的私钥pkcs8_private_key.pem
 $ openssl pkcs8 -topk8 -in private_key.pem -out pkcs8_private_key.pem -nocrypt
 //PS：这里生成的私钥和上面生成的公钥可以使用encryptString:publicKey和decryptString:privateKey:进行RSA加密和解密
 
 8、生成JAVA支持的PKCS8二进制类型的私钥：(ps:用于java解密)
 $ openssl pkcs8 -topk8 -inform PEM -in private_key.pem -outform DER -nocrypt -out pkcs8_private_key.der
 
 二、使用在线工具生成秘钥对
 http://web.chacuo.net/netrsakeypair
 */

@interface RSACryptor : NSObject

/**
 *  加密方法
 *
 *  @param data   需要加密的data
 *  @param path  '.der'格式的公钥文件路径
 */
+ (NSData *)encryptData:(NSData *)data publicKeyWithContentsOfFile:(NSString *)path;

/**
 *  解密方法
 *
 *  @param data       需要解密的data
 *  @param path      '.p12'格式的私钥文件路径
 *  @param password  私钥文件密码
 */
+ (NSData *)decryptData:(NSData *)data privateKeyWithContentsOfFile:(NSString *)path password:(NSString *)password;

/**
 *  加密方法
 *
 *  @param data    需要加密的data
 *  @param pubKey 公钥字符串
 */
+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;

/**
 *  解密方法
 *
 *  @param data     需要解密的data
 *  @param privKey 私钥字符串
 */
+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey;

/// RSA签名
/// @param data 签名的data
/// @param privKey 私钥
+ (NSData *)signatureData:(NSData *)data privateKey:(NSString *)privKey;

/// 验证RSA签名
/// @param data 验证的data
/// @param signatureData 签名
/// @param pubKey 公钥
+ (BOOL)verifyData:(NSData *)data signature:(NSData *)signatureData publicKey:(NSString *)pubKey;

@end


