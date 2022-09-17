//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Islom Babaev on 17/09/22.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
    private init() {}
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(
            loader: { commentsLoader().dispatchOnMainQueue() }
        )
        
        let feedController = makeWith(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource

        let presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: { _ in
                    Empty<Data,Error>()
                        .dispatchOnMainQueue()
                        .eraseToAnyPublisher()
                }
            ),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map
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
