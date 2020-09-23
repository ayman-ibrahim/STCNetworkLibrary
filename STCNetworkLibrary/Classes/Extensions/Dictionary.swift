//
//  Dictionary.swift
//  STCNetworkCore
//
//  Created by Ayman Ibrahim on 16/01/2020.
//  Copyright © 2020 STC. All rights reserved.
//

import Foundation


public extension Dictionary where Value: Equatable {
    
    func allKeys(forValue val: Value) -> [Key] {
        return filter { $1 == val }.map { $0.0 }
    }
}
