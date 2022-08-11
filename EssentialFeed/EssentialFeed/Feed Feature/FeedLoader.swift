//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 28/07/22.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage],Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
