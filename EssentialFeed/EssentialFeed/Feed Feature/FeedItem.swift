//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 28/07/22.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
