//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Islom Babaev on 22/08/22.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            location: image.location,
            description: image.description
        )
    }
}
