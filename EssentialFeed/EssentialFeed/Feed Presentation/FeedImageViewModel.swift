//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 22/08/22.
//

import Foundation

public struct FeedImageViewModel {
    public let location: String?
    public let description: String?
    
    public var hasLocation: Bool {
        location != nil
    }
}
