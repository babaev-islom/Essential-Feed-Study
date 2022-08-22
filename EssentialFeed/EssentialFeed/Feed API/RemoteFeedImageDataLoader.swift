//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 22/08/22.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    private struct Task: FeedImageDataLoaderTask {
        private let wrapped: HTTPClientTask
        
        init(_ wrapped: HTTPClientTask) {
            self.wrapped = wrapped
        }
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
        
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                guard response.statusCode == 200, !data.isEmpty else {
                    return completion(.failure(Error.invalidData))
                }
                completion(.success(data))
            }
        }
        return Task(task)
    }
}
