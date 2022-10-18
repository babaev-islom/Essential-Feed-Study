//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 23/08/22.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
        
    public func insert(_ data: Data, for url: URL) throws {
        try performSync { context in
            Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            }
        }
    }
    
    public func retrieve(dataForURL url: URL) throws -> Data? {
        try performSync { context in
            Result {
                return try ManagedFeedImage.first(with: url, in: context)?.data
            }
        }
    }

}
