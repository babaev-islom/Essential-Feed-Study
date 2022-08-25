//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 25/08/22.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Swift.Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
