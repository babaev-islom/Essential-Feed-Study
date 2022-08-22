//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 22/08/22.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let location: String?
    public let description: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        location != nil
    }
}
