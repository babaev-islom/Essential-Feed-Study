//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 28/07/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
