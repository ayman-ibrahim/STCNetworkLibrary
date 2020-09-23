//
//  RetryRequestLoader.swift
//  MySTC
//
//  Created by Mousa Alsahbi on 08/03/2019.
//  Copyright © 2019 STC. All rights reserved.
//

import Foundation

public struct RetryRequestLoader {
    let cachePolicy : RequestLoaderCachePolicy
    let successblock: ((ResponseDictionary, RequestLoaderCacheStatus) -> Void)
    let failureBlock: ((NSError) -> Void)

    public init(cachePolicy: RequestLoaderCachePolicy, successblock: @escaping ((ResponseDictionary,
        RequestLoaderCacheStatus) -> Void),
         failureBlock: @escaping ((NSError) -> Void)) {
        self.cachePolicy  = cachePolicy
        self.successblock = successblock
        self.failureBlock = failureBlock
    }
}
