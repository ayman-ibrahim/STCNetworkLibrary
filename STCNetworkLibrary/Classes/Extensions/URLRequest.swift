//
//  URLRequest.swift
//  STCNetworkCore
//
//  Created by Ayman Ibrahim on 16/01/2020.
//  Copyright © 2020 STC. All rights reserved.
//

import Foundation

fileprivate struct HTTPConstantss {
    enum HeaderParameters: String {
        case userAgent       = "User-Agent"
        case accept          = "Accept"
        case contentType     = "Content-Type"
        case authorization   = "Authorization"
        case date            = "date"
        case acceptLanguage  = "Accept-Language"
        case stcws           = "x-stcws-user"
        case userLocation    = "x-user-loc"
        case test            = "Test"
        case forceRefresh    = "forceRefresh"
        case apiVersion      = "x-API-Version"
        case xPin            = "X-Pin"
    }
}

class URLRequestConfiguration {
    
    var urlRequest: URLRequest
    
    init(_ urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
    func configure(request: ResourceRequest, cachePolicy: RequestLoaderCachePolicy, httpHeaderFields: [String: String], configuration: ConfigurationType) -> URLRequest {

           var headerFields = httpHeaderFields

           if cachePolicy == .forceNetworkLoad {
               headerFields[HTTPConstantss.HeaderParameters.forceRefresh.rawValue] = "true"
           }

           if let headerParameters = request.headerParameters {
               headerParameters.forEach { (key, value) in
                urlRequest.setValue(value, forHTTPHeaderField: key)
               }
           }

           /// set allHTTPHeaderFields
           headerFields.forEach { (key, value) in
               urlRequest.setValue(value, forHTTPHeaderField: key)
           }
    
           urlRequest.httpMethod = request.networkResource.httpMethod
           if urlRequest.httpMethod == HTTPMethod.post.rawValue || urlRequest.httpMethod == HTTPMethod.delete.rawValue || urlRequest.httpMethod ==  HTTPMethod.put.rawValue {
               if let parameters = request.bodyParameters {

                   let body = Dictionary(uniqueKeysWithValues: parameters.map {key, value -> (String, Any) in
                       if let inParameters =  value as? [String: Any] {
                           return (key, Dictionary(uniqueKeysWithValues: inParameters.map {return ($0, $1)}))
                       } else {
                           return (key, value)
                       }
                       
                   })

                   if request.domain == .genesys {
                       urlRequest.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: HTTPConstantss.HeaderParameters.contentType.rawValue)
                    urlRequest.httpBody = urlRequest.query(body).data(using: .utf8, allowLossyConversion: false)
                   } else {
                       urlRequest.addValue("application/json", forHTTPHeaderField: HTTPConstantss.HeaderParameters.contentType.rawValue)
                       urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
                   }

               } else {
                   /// always provide at least an empty JSON for body of POST, PUT and DELETE requests
                   urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: [String: String]())
               }
           }

           urlRequest.timeoutInterval = configuration.double(forKey: .timeoutInterval)

           switch cachePolicy {
           case .forceNetworkLoad:
               urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
           case .attemptToReturnCacheAfterError, .returnCacheThenLoadIfNeeded:
               urlRequest.cachePolicy = .returnCacheDataDontLoad
           default:
               urlRequest.cachePolicy = .useProtocolCachePolicy
           }
        
        return urlRequest
    }
}

public extension URLRequest {

    mutating func set(value: String?, key: String) {
        setValue(value, forHTTPHeaderField: key)
    }
    
//    mutating func configure(request: ResourceRequest, cachePolicy: RequestLoaderCachePolicy, httpHeaderFields: [String: String], configuration: ConfigurationType) {
//
//        var headerFields = httpHeaderFields
//
//        if cachePolicy == .forceNetworkLoad {
//            headerFields[HTTPConstantss.HeaderParameters.forceRefresh.rawValue] = "true"
//        }
//
//        if let headerParameters = request.headerParameters {
//            headerParameters.forEach { (key, value) in
//                setValue(value, forHTTPHeaderField: key)
//            }
//        }
//
//        /// set allHTTPHeaderFields
//        headerFields.forEach { (key, value) in
//            setValue(value, forHTTPHeaderField: key)
//        }
//
//        httpMethod = request.networkResource.httpMethod
//        if httpMethod == HTTPMethod.post.rawValue || httpMethod == HTTPMethod.delete.rawValue || httpMethod ==  HTTPMethod.put.rawValue {
//            if let parameters = request.bodyParameters {
//
//                let body = Dictionary(uniqueKeysWithValues: parameters.map {key, value -> (String, Any) in
//                    if let inParameters =  value as? [String: Any] {
//                        return (key, Dictionary(uniqueKeysWithValues: inParameters.map {return ($0, $1)}))
//                    } else {
//                        return (key, value)
//                    }
//
//                })
//
//                if request.domain == .genesys {
//                    addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: HTTPConstantss.HeaderParameters.contentType.rawValue)
//                    httpBody = query(body).data(using: .utf8, allowLossyConversion: false)
//                } else {
//                    addValue("application/json", forHTTPHeaderField: HTTPConstantss.HeaderParameters.contentType.rawValue)
//                    httpBody = try? JSONSerialization.data(withJSONObject: body)
//                }
//
//            } else {
//                /// always provide at least an empty JSON for body of POST, PUT and DELETE requests
//                httpBody = try? JSONSerialization.data(withJSONObject: [String: String]())
//            }
//        }
//
//        timeoutInterval = configuration.double(forKey: .timeoutInterval)
//
//        switch cachePolicy {
//        case .forceNetworkLoad:
//            self.cachePolicy = .reloadIgnoringLocalCacheData
//        case .attemptToReturnCacheAfterError, .returnCacheThenLoadIfNeeded:
//            self.cachePolicy = .returnCacheDataDontLoad
//        default:
//            self.cachePolicy = .useProtocolCachePolicy
//        }
//    }
}

extension URLRequest {
    
    func cURL() -> String {
        var headerString = ""
        allHTTPHeaderFields?.forEach({ (key, value) in
            headerString.append("-H \"\(key):\(value)\" ")
        })
        
        var bodyString = ""
        if let body = httpBody {
            do {
                let data   = try JSONSerialization.jsonObject(with: body, options: .allowFragments)
                bodyString = "-d \"\(data)\""
            } catch {
                
            }
        }
        
        let method = httpMethod ?? ""
        let urlString = url?.absoluteString ?? ""
        return "curl -i \(headerString) \(bodyString)-X \(method) \(urlString)"
    }
}
