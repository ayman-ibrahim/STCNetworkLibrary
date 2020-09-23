//
//  String.swift
//  STCNetworkCore
//
//  Created by Ayman Ibrahim on 16/01/2020.
//  Copyright © 2020 STC. All rights reserved.
//

import Foundation
import CommonCrypto

public extension String {
    var boolValue: Bool {
        let yValues = ["1", "true", "y", "yes", "ok"]
        return yValues.contains(lowercased())
    }
    
    func base64() -> String {
        return Data(utf8).base64EncodedString()
    }

    func aes128CBCEncrypte(by key: String) -> String {
        guard let data = self.data(using: String.Encoding.utf8) else { return "" }
        guard let keyData = key.data(using: String.Encoding.utf8) else { return "" }
        guard let encryptedData = try? data.aes128CBCEncrypte(by: keyData) else { return "" }
        return encryptedData.base64EncodedString()
    }


    func hmac(algorithm: HMACAlgorithm, key: String) -> String {
        let cKey   = key.cString(using: String.Encoding.utf8)
        let cData  = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), cKey!, Int(strlen(cKey!)), cData!, Int(strlen(cData!)), &result)
        let hmacData: NSData = NSData(bytes: result, length: (Int(algorithm.digestLength())))
        let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
        return String(hmacBase64)
    }
}
