//
//  ErrorItem.swift
//  STCNetworkCore
//
//  Created by Ayman Ibrahim on 16/01/2020.
//  Copyright © 2020 STC. All rights reserved.
//

import Foundation


public struct ErrorMessage: Codable {
    public let errors: [ErrorItem]?
}

public struct ErrorItem: Codable {
    public let code: String?
    public let message: String?
}
