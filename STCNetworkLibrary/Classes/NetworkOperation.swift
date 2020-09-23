//
//  NetworkOperation.swift
//  MySTC
//
//  Created by Mousa Alsahbi on 16/01/2018.
//  Copyright © 2018 STC. All rights reserved.
//

import Foundation

public protocol ResponseMapperType {
    var contentMapper: [String: Any] { set get }
}

public typealias ResponseDictionary = [String: Any]
public typealias HTTPStatusCode     = Int

private var URLSessionTaksOperationKVOContext = 0

///Abstract Class
public class NetworkOperation: AsynchronousOperation {
    
    public var response: HTTPURLResponse?
    
    /// The error, if any, that occurred during execution of the operation.
    /// A `nil` error value indicates that the operation completed successfully.
    public var error: NSError?
    
    /// The data received during the request.
    public var responseData: Data?
    
    /// The Mapped response object.
    public var mappedResponse: Any?
    
    public let request: ResourceRequest
    public let cachePolicy: RequestLoaderCachePolicy
    public let responseMapper: ResponseMapperType
    public let httpHeaderFileds: [String: String]
    public let configuartion: ConfigurationType
    
    /// Executed before the deserialized response is passed to the mapper.
    public let willMapDeserializedResponseBlock: ((Any) -> Any)?
    
    public init(request: ResourceRequest, cache: RequestLoaderCachePolicy, reponseMapper: ResponseMapperType, httpHeaderFields: [String: String], configuration: ConfigurationType) {
        self.cachePolicy                      = cache
        self.request                          = request
        self.willMapDeserializedResponseBlock = request.willMapDeserializedResponseBlock
        self.responseMapper                   = reponseMapper
        self.httpHeaderFileds                 = httpHeaderFields
        self.configuartion                    = configuration
        super.init()
        self.name                             = request.resultsKey
    }
    
    public var isOptional: Bool {
        return self.request.isOptional
    }
    
    public lazy var task: URLSessionTask = {
        let urlRequest = request.setupURLRequest(with: cachePolicy, httpHeaderFields: self.httpHeaderFileds, configuration: self.configuartion)
        return URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, _, _) in
            self.responseData = data
            self.handleResponse()
            self.finish()
        })
    }()
    
    // MARK: - Override

    public override func execute() {
        assert(task.state == .suspended, "Task was resumed by something other than \(self).")
        task.addObserver(self, forKeyPath: "state", options: [], context: &URLSessionTaksOperationKVOContext)
        task.resume()
        if let currentRequest = task.currentRequest {
            print("\(currentRequest.cURL())")
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &URLSessionTaksOperationKVOContext else { return }
        if object as? URLSessionTask == task && keyPath == "state" && task.state == .completed {
            if task.observationInfo != nil {
                task.removeObserver(self, forKeyPath: "state")
            }
        }
    }
    
    public override func finish() {
        super.finish()
    }
    
    public override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    func decodeRespons(_ responseJSON: Any) {
        do {
            let data = try JSONSerialization.data(withJSONObject: responseJSON, options: .prettyPrinted)
            if let className = self.responseMapper.contentMapper[request.resultsKey] {
                let contentClassName = className as! Codable.Type
                mappedResponse = try contentClassName.init(jsonData: data)
            } else {
                mappedResponse = nil
            }
        } catch let (error as NSError ) {
            self.error = NSError(domain: error.domain, code: error.code, userInfo: error.userInfo)
        }
    }
}

// TODO: It needs code refactoring
extension NetworkOperation {
    
    func handleResponse() {
        if let operationError = task.error {
            error = operationError as NSError
        } else {
            if let operationResponse = task.response as? HTTPURLResponse {
                response = operationResponse
                let statusCode = operationResponse.statusCode
                switch statusCode {
                case 200...204:
                    handleSuccessResponse(statusCode: statusCode, data: responseData)
                default:
                    handleErrorResponse(statusCode: statusCode, data: responseData)
                }
            }
        }
    }
    
    func handleSuccessResponse(statusCode: Int, data: Data?) {
        if statusCode == 204 {
            mappedResponse = [:]
        } else if let data = data {
            if !request.isDataRequest {
                do {
                    var responseJSON: Any? = try JSONSerialization.jsonObject(with: data, options: []) as? ResponseDictionary
                    print(responseJSON ?? "no reponse data")
                    if let deserializedResponse = self.willMapDeserializedResponseBlock, let json = responseJSON {
                        responseJSON = deserializedResponse(json)
                    }
                    
                    if let responseJSON = responseJSON {
                        self.decodeRespons(responseJSON)
                    }
                } catch let (error as NSError) {
                    self.error =  NSError(domain: error.domain, code: error.code, userInfo: error.userInfo)
                }
            } else {
                mappedResponse = data
            }
        }
        
    }
    
    func handleErrorResponse(statusCode: Int, data: Data?) {
        let errorItem = ErrorItem(code: nil, message: NSError().genericErrorMessage)
        let genericError = NSError(domain: ErrorConstants.AppErrorDomain, code: statusCode, errorMessage: errorItem)
        if let data = data {
            do {
                let message = try JSONDecoder().decode(ErrorMessage.self, from: removeNewLine(from: data))
                if let error = message.errors?.first {
                    self.error = NSError(domain: ErrorConstants.AppErrorDomain, code: statusCode, errorMessage: error)
                } else {
                    self.error = genericError
                }
            } catch let (error as NSError ) {
                self.error = NSError(domain: error.domain, code: error.code, userInfo: error.userInfo)
            }
        } else {
            self.error = genericError
        }
    }
}

private func removeNewLine(from data: Data) -> Data {
    var dataString = String(decoding: data, as: UTF8.self)
    dataString = dataString.replacingOccurrences(of: "\n", with: "")
    return dataString.data(using: .utf8) ?? data
}

/// Work around to solve the generic mapping
public class NetworkRequestOperation<T: Codable>: NetworkOperation {
    public override func decodeRespons(_ responseJSON: Any) {
        do {
            let data = try JSONSerialization.data(withJSONObject: responseJSON, options: .prettyPrinted)
            mappedResponse = try JSONDecoder().decode(T.self, from: data)
        } catch let (error as NSError ) {
            self.error = NSError(domain: error.domain, code: error.code, userInfo: error.userInfo)
        }
    }
}
