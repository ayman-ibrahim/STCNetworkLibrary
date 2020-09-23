//
//  NSError.swift
//  STCNetworkCore
//
//  Created by Ayman Ibrahim on 16/01/2020.
//  Copyright © 2020 STC. All rights reserved.
//

import Foundation


public struct ErrorConstants {
    public static let ErrorItemCode    = "ErrorItemCode"
    public static let errorItemMessage = "errorItemMessage"
    public static let AppErrorDomain           = "AppErrorDomain"
    public static let LocalizedDescriptionkey  = "localizedDescription"
    public static let AppErrorCodekey          = "errorCode"
}

public extension NSError {
    
    convenience init(domain: String, code: Int, errorMessage: ErrorItem) {
        let messageCode = errorMessage.code ?? ""
        let message     = errorMessage.message ?? NSError().genericErrorMessage
        self.init(domain: domain, code: code, userInfo: [ErrorConstants.ErrorItemCode: messageCode, ErrorConstants.errorItemMessage: message])
    }
}

public extension NSError {

    var errorMessageCode: String {
        if let errorCode = userInfo[ErrorConstants.ErrorItemCode] as? String {
            return errorCode
        }
        return "-0"
    }
    
    var errorMessageString: String {
        if let errorMessage = userInfo[ErrorConstants.errorItemMessage] as? String {
            return errorMessage
        }
        return genericErrorMessage
    }
    
    var localizedUserFriendlyDescription: String {
        if domain == NSURLErrorDomain {
            if code == NSURLErrorNotConnectedToInternet {
                return "No Internet connection"
            }
        }
        
        return errorMessageString
    }
    
    var genericErrorMessage: String {
        return "This service is currently unavailable."
    }
}
