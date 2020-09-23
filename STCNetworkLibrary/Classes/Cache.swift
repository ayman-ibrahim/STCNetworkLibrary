//
//  Cache.swift
//  MySTC
//
//  Created by Mousa Alsahbi on 19/01/2018.
//  Copyright © 2018 STC. All rights reserved.
//

import Foundation

public class Cache: URLCache {
    
    open class func setupURLCache(language identifier: String) {
        let cache = Cache(memoryCapacity: 512000, diskCapacity: 10000000, diskPath: "stcURLCache_" + identifier)
        URLCache.shared = cache
    }
    
    public override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        let cachedResponse  = super.cachedResponse(for: request)
        #if DEBUG
        if let httpResponse = cachedResponse?.response as? HTTPURLResponse, let urlString = request.url?.absoluteString {
            print("Providing response cached at \(String(describing: httpResponse.allHeaderFields["Date"])) for \(urlString)")
        }
        #endif
        return cachedResponse
    }
    
    public override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        #if DEBUG
        
        if let httpResponse = cachedResponse.response as? HTTPURLResponse, let urlString = request.url?.absoluteString {
            print("Caching response at \(String(describing: httpResponse.allHeaderFields["Date"])) for \(urlString)")
        }
        #endif
        
        super.storeCachedResponse(cachedResponse, for: request)
    }
    
    public override func removeCachedResponse(for request: URLRequest) {
        #if DEBUG
        let urlString = request.url?.absoluteString ?? ""
        print("Removing cached response for \(urlString)")
        #endif
        
        super.removeCachedResponse(for: request)
    }
}
