//
//  NetworkResource.swift
//  MySTC
//
//  Created by Mousa Alsahbi on 16/01/2018.
//  Copyright © 2018 STC. All rights reserved.
//

import Foundation

public protocol ResourceType {
    func resolvedPath(pathParameters: [String: String]?, queryParameters: [String: String]?) -> String
    func baseURL() -> String
    func createURL(for resource: ResourceType, with path: String) -> URL
    func networkOperation(request: ResourceRequest, cachePolicy: RequestLoaderCachePolicy) -> NetworkOperation
    
    var domain          : Domain                { get }
    var identity        : String                { get }
    var path            : String                { get }
    var httpMethod      : String                { get }
    var responseMapper  : ResponseMapperType    { get }
    var httpHeaderFileds: [String: String]      { get }
    var configuartion   : ConfigurationType     { get }
}
