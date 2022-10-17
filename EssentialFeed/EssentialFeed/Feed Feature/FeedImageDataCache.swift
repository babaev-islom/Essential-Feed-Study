//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 25/08/22.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
