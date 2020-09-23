//
//  Date.swift
//  STCNetworkCore
//
//  Created by Ayman Ibrahim on 16/01/2020.
//  Copyright © 2020 STC. All rights reserved.
//

import Foundation

public extension Date {
    func englishGregorianDateAsString(timezone: TimeZone, format: String) -> String {
        let dateFormatter        = DateFormatter()
        dateFormatter.calendar   = Calendar(identifier: .gregorian)
        dateFormatter.locale     = Locale(identifier: "en_GB")
        dateFormatter.timeZone   = timezone
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    static func gregorianDate(timezone: TimeZone, stringDate: String, format: String) -> Date? {
        if stringDate.count == 0 {return nil}
        
        let dateFormatter        = DateFormatter()
        dateFormatter.calendar   = Calendar(identifier: .gregorian)
        dateFormatter.locale     = Locale(identifier: "en_GB")
        dateFormatter.timeZone   = timezone
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: stringDate)
    }
}
