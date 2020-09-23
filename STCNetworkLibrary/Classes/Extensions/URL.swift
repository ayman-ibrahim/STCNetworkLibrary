//
//  URL.swift
//  STCNetworkCore
//
//  Created by Ayman Ibrahim on 16/01/2020.
//  Copyright © 2020 STC. All rights reserved.
//

import Foundation

public extension URL {
    
    func createURL(with path: String) -> URL {
        let aPath = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? path
        return URL(string: absoluteString + aPath)!
    }
}
