//
//  RequestConfig.swift
//  MySTC
//
//  Created by Sameh Saeed on 18/02/2019.
//  Copyright © 2019 STC. All rights reserved.
//

import Foundation

public enum ConnectionType: String {
    case `public`
    case `private`
}

public protocol Route {
    var networkResource: ResourceType { get }
}
