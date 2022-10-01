//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Islom Babaev on 16/08/22.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    private init() {}
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void = { _ in }
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(
            loader: { feedLoader().dispatchOnMainQueue() }
        )
        
        let feedController = makeWith(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource

        let presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: {
                    imageLoader($0)
                        .dispatchOnMainQueue()
                        .eraseToAnyPublisher()
                },
                selection: selection
            ),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: { $0 }
        )
        presentationAdapter.presenter = presenter
        return feedController
    }
    
    private static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}

