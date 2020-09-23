//
//  Enumeration.swift
//  MySTC
//
//  Created by Mousa Alsahbi on 08/03/2019.
//  Copyright © 2019 STC. All rights reserved.
//

import Foundation

public enum Domain: String {
    case stc
    case google
    case genesys
}

public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

public enum RequestLoaderCachePolicy {
    /// use the caching logic defined in the protocol implementation
    case `default`
    /// for user instigated reload - forces cache to be ignored for all requests in the load - set back to NO when load begins
    case forceNetworkLoad
    /// if cache data exists (fresh or expired), the success block will be called with this data, before potentially being called a second time after going to network
    case returnCacheThenLoadIfNeeded
    /// if network error occurs, will attempt to satisfy requests with stale cached objects
    case attemptToReturnCacheAfterError
}

public enum RequestLoaderState: String {
    case idel
    case unloaded
    case loading
    case loaded
    case empty
    case error
    case cancelled
}

public enum RequestLoaderCacheStatus {
    case fresh
    case stale
}
