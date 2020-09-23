//
//  RequestLoader.swift
//  MySTC
//
//  Created by Mousa Alsahbi on 16/01/2018.
//  Copyright © 2018 STC. All rights reserved.
//

import Foundation

open class RequestLoader {

    /// set when calling one of the loadWithRequests: methods and resused when calling loadWithOptions:successBlock:failureBlock
    private(set) var requests                 : [ResourceRequest]?

    /// the error that produced ResourceLoaderError state
    private(set) var lastNSError              : NSError?

    /// the associated HTTP statusCode of lastError
    private(set) var lastNSErrorHTTPStatusCode: Int?

    /// the date until which the current data can be considered 'fresh' - if the data comes from multiple requests, this will be based on the response which is due to expire the soonest
    private(set) var cacheUntil               : Date?

    /// this will be re-populated after every successful load (and when not satisfied by the local cache)
    private(set) var loadedObjects            : [String: Any]?

    /// if this is set to true, any provided ResourceLoaderOptions will be overriden with just ResourceLoaderOptionForceNetworkLoad - useful for user refresh/retries etc
    /// NB - will be set back to false when load begins
    public var forceNetworkForNextLoad               : Bool = false

    /// set to ture just before forced network load begins, then returns to false just after load completes/fails
    private(set) var isForcingNetworkLoad     : Bool = false

    /// KVO compliant
    public lazy var loadState = Observable<RequestLoaderState, RequestLoader>(.idel, eventRaiser: self)

    ///
    private(set) var retryRequestLoader: RetryRequestLoader?

    /// returns true if at least one request has been set
    public var isConfigured: Bool {
        if let requests = requests {
            return requests.count > 0
        }
        return false
    }

    /// keep a reference to this so we can cancel the operations easily
    public var runningObjectRequests: [NetworkOperation] = [NetworkOperation]()
    
    ///
    public let configuartion: ConfigurationType

    /// if fetchRequest is set, returns true if fetchedObjects.count > 0, otherwise true if loadedObjects.count > 0
    public var hasData: Bool {
        if let loadedObjs = loadedObjects {
            return loadedObjs.keys.count > 0
        }
        return false
    }

    /// one time configuration - calling this again will reset the object loader completely
    public func configure(with requests: [ResourceRequest]) {
        /// reset everything
        self.requests = requests
        loadState.set(newValue: .unloaded)
    }

    ///
    public func retryloadRequests() {
        if let retryRequest = retryRequestLoader {
            loadRequests(cachePolicy: retryRequest.cachePolicy, configuration: self.configuartion, successBlock: retryRequest.successblock, failureBlock: retryRequest.failureBlock)
        }
    }
    
    public init(configuration: ConfigurationType) {
        self.configuartion = configuration
    }

    /// load using configured requests - will update loadState and reset lastError,
    /// NB - if the local cache is still valid (determined by cacheUntil), then the successBlock is not called - the assumption here is that the viewController is already configured correctly from the original load, and we don't want to do extra work
    /// NB - set '.returnCacheThenLoadIfNeeded' to override this behaviour and force the successBlock to be called in this case
    public func loadRequests(cachePolicy   : RequestLoaderCachePolicy,
                      configuration : ConfigurationType,
                      successBlock successblock: @escaping ((ResponseDictionary, RequestLoaderCacheStatus) -> Void),
                      failureBlock failureblock: @escaping ((NSError) -> Void)) {

        var requestCachePolicy = cachePolicy

        if forceNetworkForNextLoad {
            /// override provided options and force network refresh
            requestCachePolicy      = .forceNetworkLoad
            forceNetworkForNextLoad = false
        }

        if let cacheUntil = self.cacheUntil {
            if requestCachePolicy != .forceNetworkLoad && Date() < cacheUntil {
                if requestCachePolicy == .returnCacheThenLoadIfNeeded || requestCachePolicy == .none {
                    if let loadedObjects = self.loadedObjects {
                        successblock(loadedObjects, .fresh)
                        return
                    }
                }
            }
        }

        assert(isConfigured, "Cannot perform load until resourceLoader has been configured")

        if loadState.get() == .loading {
            /// maybe we can do something cleverer here like store all success/failure blocks and call them all?
            debugPrint("Load already in progress")
            return
        }

        guard let requests = self.requests else {
            return
        }

        retryRequestLoader        = RetryRequestLoader(cachePolicy: cachePolicy, successblock: successblock, failureBlock: failureblock)
        lastNSError               = nil
        lastNSErrorHTTPStatusCode = 0
        isForcingNetworkLoad      = requestCachePolicy == .forceNetworkLoad
        loadState.set(newValue: .loading)

        perform(requests: requests, cachePolicy: requestCachePolicy, configuration: self.configuartion, successBlock: successblock, failureBlock: failureblock)
    }

    private func perform(requests       : [ResourceRequest],
                         cachePolicy    : RequestLoaderCachePolicy,
                         configuration  : ConfigurationType,
                         successBlock  successblock:@escaping ((ResponseDictionary, RequestLoaderCacheStatus) -> Void),
                         failureBlock  failureblock:((NSError) -> Void)?) {

        var operations: [NetworkOperation] = []

        for request in requests {
            operations.append(request.networkOperation(cachePolicy: cachePolicy))
        }

        runningObjectRequests = operations
        var earliestExpiryDate = Date.distantFuture
        operations.onFinish { [weak self] completedOperations in
            self?.loadedObjects     = [:]
            for operation in completedOperations {
                if let error = operation.error {
                    let statusCode = operation.response?.statusCode ?? 0
                    if statusCode != 401 && statusCode == 404 {
                        /// treat 404 as success
                        self?.loadState.set(newValue: .empty)
                    } else if statusCode != 401 && operation.isCancelled {
                        self?.loadState.set(newValue: .cancelled)
                        return
                    } else {
                        let returnCache  = cachePolicy == .returnCacheThenLoadIfNeeded || cachePolicy == .attemptToReturnCacheAfterError
                        let errorHandled = self?.handle(error: error, for: operation, statusCode: statusCode, returnCache: returnCache, failureBlock: failureblock)
                        if !(errorHandled ?? false) {
                            return
                        }
                    }
                }

                self?.loadedObjects?[operation.name ?? ""]  = operation.mappedResponse ?? [:]

                /// determine if this response has the earliest expiry date of all responses so far
                if configuration.bool(forKey: .overrideCachePeriods), let expiry = operation.response?.responseDate().addingTimeInterval(self?.configuartion.double(forKey: .cachePeriod) ?? 0) {
                    earliestExpiryDate = expiry
                }
                else if let cacheUntil = operation.response?.cacheUntil() {
                    earliestExpiryDate = cacheUntil
                }
            }
            self?.cacheUntil  = earliestExpiryDate
            let cacheIsStale = Date() > earliestExpiryDate
            self?.loadState.set(newValue: .loaded)
            if let loadedObjects = self?.loadedObjects {
                successblock(loadedObjects, cacheIsStale ? .stale : .fresh)
            }
        }
    }

    public func handle(error operationError: NSError, for operation: NetworkOperation, statusCode: HTTPStatusCode, returnCache: Bool, failureBlock failureblock: ((NSError) -> Void)?) -> Bool {

        var errorHandled = false

        if statusCode != 401 && operation.isOptional {
            /// don't fail on optional requests
            errorHandled = true
        } else {
            let failedToReturnCache = returnCache && operationError.code == NSURLErrorResourceUnavailable
            if !failedToReturnCache {
                self.lastNSError               = operationError
                self.lastNSErrorHTTPStatusCode = statusCode
                self.loadState.set(newValue: .error)
            }

            if let failureblock = failureblock {
                failureblock(operationError)
            }
        }
        return errorHandled
    }

    /// will set loadState to '.cancelled' only if one of the requests is actually cancelled
    public func cancelLoading() {
        let requestsToCancel  = runningObjectRequests
        runningObjectRequests.removeAll()
        requestsToCancel.forEach { request in
            request.cancel()
        }
        loadState.set(newValue: .cancelled)
    }
}

// MARK: - Equatable
extension RequestLoader: Equatable {
    public static func == (lhs: RequestLoader, rhs: RequestLoader) -> Bool {
        if let lRequests = lhs.requests, let rRequests = rhs.requests {
            return lRequests == rRequests
        }
        return false
    }
}
