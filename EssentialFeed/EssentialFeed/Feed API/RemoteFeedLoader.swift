//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 01/08/22.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error, Equatable {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult<Error>
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
