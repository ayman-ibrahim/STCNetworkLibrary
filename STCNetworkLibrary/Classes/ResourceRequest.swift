//
//  ResourceRequest.swift
//  MySTC
//
//  Created by Mousa Alsahbi on 16/01/2018.
//  Copyright © 2018 STC. All rights reserved.
//

import Foundation

public protocol ResourceRequestProtocol {
    associatedtype T: (Hashable & RawRepresentable)
    associatedtype V: (Hashable & RawRepresentable)
    var pathParameters                  : [T: String]? { get set }
    var bodyParameters                  : [T: Any]?    { get set }
    var queryParameters                 : [T: String]? { get set }
    
    var headerParameters                : [V: String]? { get set }
}

open class ResourceRequest {
    public var networkResource                 : ResourceType
    public let domain                          : Domain
    
    /// A dictionary of parameters to apply to a `URLRequest`.
    open var pathParameters                  : [String: String]?
    open var bodyParameters                  : [String: Any]?
    open var queryParameters                 : [String: String]?

    /// to be executed before the response mapper operation begins mapping the deserialized response body,
    /// providing an opportunity to manipulate the mappable representation input before mapping begins.
    public var willMapDeserializedResponseBlock: ((Any) -> Any)?
    
    /// i.e. we are expecting a file, not JSON, default is 'false'
    public var isDataRequest                   : Bool = false
    
    /// won't cause whole batch to fail on error, default is 'false'
    public var isOptional                      : Bool = false

    /// i.e. if you want send a request over HTTPs, default is 'true'
    public var isSecured                       : Bool = true

    /// A dictionary of header parameters to apply to a `header of Request`, default is 'nil'
    public var headerParameters                : [String: String]? = nil


    /// this is used as a key when returning results in dictionaries.
    public var resultsKey: String {
        if let contentCategory = pathParameters?["category"] {
            if let contentKey = pathParameters?["key"] {
                return contentKey
            }
            return contentCategory
        }
        return networkResource.identity
    }
    
    public init(with route: Route) {
        self.networkResource = route.networkResource
        self.domain          = route.networkResource.domain
    }
}

// MARK: - Util
extension ResourceRequest {

    public func setupURLRequest(with cachePolicy: RequestLoaderCachePolicy, httpHeaderFields: [String: String], configuration: ConfigurationType) -> URLRequest {
        let path            = networkResource.resolvedPath(pathParameters: pathParameters, queryParameters: queryParameters)
        var url             = networkResource.createURL(for: networkResource, with: path)
        
        if !isSecured, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            urlComponents.scheme = "http"
            url = urlComponents.url!
        }
        
        let urlRequest      = URLRequest(url: url)
        let configuartion = URLRequestConfiguration(urlRequest)
        return configuartion.configure(request: self, cachePolicy: cachePolicy, httpHeaderFields: httpHeaderFields, configuration: configuration)
    }

    public func networkOperation(cachePolicy: RequestLoaderCachePolicy) -> NetworkOperation {
        return self.networkResource.networkOperation(request: self, cachePolicy: cachePolicy)
    }
}

// MARK: - Equatable
extension ResourceRequest: Equatable {
    public static func == (lhs: ResourceRequest, rhs: ResourceRequest) -> Bool {
        return lhs.networkResource.identity == rhs.networkResource.identity && lhs.pathParameters == rhs.pathParameters && lhs.queryParameters == rhs.queryParameters
    }
}
