//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Islom Babaev on 24/08/22.
//

import Foundation
import EssentialFeed

//public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
//    private let primary: FeedImageDataLoader
//    private let fallback: FeedImageDataLoader
//    
//    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
//        self.primary = primary
//        self.fallback = fallback
//    }
//    
//    private final class TaskWrapper: FeedImageDataLoaderTask {
//        var wrapped: FeedImageDataLoaderTask?
//        
//        func cancel() {
//            wrapped?.cancel()
//        }
//    }
//    
//    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
//        let task = TaskWrapper()
//        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
//            switch result {
//            case .success:
//                completion(result)
//            case .failure:
//                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
//            }
//        }
//        return task
//    }
//}
