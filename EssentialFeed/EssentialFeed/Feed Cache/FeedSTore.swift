//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 03/08/22.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    typealias InsertionCompletion = (Error?) -> Void
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

