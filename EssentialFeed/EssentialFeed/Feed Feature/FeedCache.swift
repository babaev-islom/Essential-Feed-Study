//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 25/08/22.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
