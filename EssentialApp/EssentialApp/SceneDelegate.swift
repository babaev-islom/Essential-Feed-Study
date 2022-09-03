//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Islom Babaev on 24/08/22.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var remoteFeedLoader: () -> FeedLoader.Publisher = {
        return { [httpClient] in
            httpClient
                .getPublisher(url: URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!)
                .tryMap(FeedItemsMapper.map)
                .eraseToAnyPublisher()
        }
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite")
            )
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
 
    func configureWindow() {
        let feedViewController = UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: makeLocalFeedImageDataLoaderWithRemoteFallback
            )
        )

        window?.rootViewController = feedViewController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        return remoteFeedLoader()
                .caching(to: localFeedLoader)
                .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeLocalFeedImageDataLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(url: url)
            .fallback(to: {
                remoteImageLoader.loadImageDataPublisher(url: url)
                    .caching(to: localImageLoader, using: url)
            })
    }
}
