//
//  Configuration.swift
//  STCNetworkCore
//
//  Created by Ayman Ibrahim on 16/01/2020.
//  Copyright © 2020 STC. All rights reserved.
//

import Foundation

public enum ConfigurationKeys: String {
    case baseURL              = "BASE URL"
    case requestTest          = "REQUEST TEST"
    case channel              = "CHANNEL"
    case timeoutInterval      = "TIMEOUT INTERVAL"
    case appVersion           = "CFBundleShortVersionString"
    case buildVersion         = "CFBundleVersion"
    case overrideCachePeriods = "OVERRIDE CACHE PERIODS"
    case cachePeriod          = "CACHE PERIOD"
    case paymentPostpaidMerchantIdentifier = "PAYMENT POSTPAID MERCHANT IDENTIFIER"
    case paymentPrepaidMerchantIdentifier = "PAYMENT PREPAID MERCHANT IDENTIFIER"
}

public protocol ConfigurationType {
    func double(forKey key: ConfigurationKeys) -> Double
    func string(forKey key: ConfigurationKeys) -> String
    func bool(forKey key: ConfigurationKeys) -> Bool
}

