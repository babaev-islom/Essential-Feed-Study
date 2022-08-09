//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 04/08/22.
//

import Foundation

struct RemoteFeedItem: Decodable {
   let id: UUID
   let description: String?
   let location: String?
   let image: URL
}
