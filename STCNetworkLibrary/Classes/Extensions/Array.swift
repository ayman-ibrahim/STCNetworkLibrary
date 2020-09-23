//
//  Array.swift
//  STCNetworkCore
//
//  Created by Ayman Ibrahim on 16/01/2020.
//  Copyright © 2020 STC. All rights reserved.
//

import Foundation


public extension Array where Element: NetworkOperation {
    /// Execute block after all operations from the array.
    func onFinish(block: (([NetworkOperation]) -> Swift.Void)?) {

        let operations       = self
        let operationQueue   = OperationQueue()
        //let dispatchGroup    = DispatchGroup()

        let batchedOperation = BlockOperation.init {
            if let completionBlock = block {
                completionBlock(operations)
            }
        }

        for operation in operations {
            let originalCompletionBlock = operation.completionBlock
            operation.completionBlock = {
                if originalCompletionBlock != nil {
                    originalCompletionBlock!()
                }
            }

            //dispatchGroup.enter()
            batchedOperation.addDependency(operation)
            operationQueue.addOperation(operation)
        }
        operationQueue.addOperation(batchedOperation)
        //operationQueue.waitUntilAllOperationsAreFinished()
    }
}
