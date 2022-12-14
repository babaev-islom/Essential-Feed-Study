//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Islom Babaev on 25/08/22.
//

import Foundation
import EssentialFeed
//
//public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
//    private let decoratee: FeedImageDataLoader
//    private let cache: FeedImageDataCache
//
//    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
//        self.decoratee = decoratee
//        self.cache = cache
//    }
//
//    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
//        decoratee.loadImageData(from: url) { [weak self] result in
//            completion(result.map { data in
//                self?.cache.saveIgnoringResult(data, for: url)
//                return data
//            })
//        }
//    }
//}
//
extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        try? save(data, for: url)
    }
}
