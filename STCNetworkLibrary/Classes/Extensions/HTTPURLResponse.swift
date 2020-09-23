//
//  HTTPURLResponse.swift
//  STCNetworkCore
//
//  Created by Ayman Ibrahim on 16/01/2020.
//  Copyright © 2020 STC. All rights reserved.
//

import Foundation


public extension HTTPURLResponse {
    
    func cacheDuration() -> Double {
        if let cacheControlHeader = allHeaderFields["Cache-Control"] as? String {
            let cacheDuration     = cacheControlHeader.replacingOccurrences(of: "max-age=", with: "")
            if let duration       = Double(cacheDuration) {
                return duration
            }
        }
        return 0.0
    }

    func responseDate() -> Date {
        if let responseDateString = allHeaderFields["Date"] as? String {
            if let responseDate = Date.gregorianDate(timezone: TimeZone(secondsFromGMT: 0)!, stringDate: responseDateString, format: "EEE, dd MMM yyyy HH:mm:ss z") {
                return responseDate
            }
        }
        return Date(timeIntervalSince1970: 0)
    }

    func cacheUntil() -> Date {
        return responseDate().addingTimeInterval(cacheDuration())
    }

}
