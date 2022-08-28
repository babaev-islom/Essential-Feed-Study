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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
//        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
//        let remoteclient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
//        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteclient)
//        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteclient)
//
//        let localStoreURL = NSPersistentContainer
//            .defaultDirectoryURL()
//            .appendingPathComponent("feed-store.sqlite")
//
//        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
//        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
//        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
//
//        let feedViewController = FeedUIComposer.feedComposedWith(
//            feedLoader: FeedLoaderWithFallbackComposite(
//                primary: FeedLoaderCacheDecorator(
//                    decoratee: remoteFeedLoader,
//                    cache: localFeedLoader
//                ),
//                fallback: localFeedLoader
//            ),
//            imageLoader: FeedImageDataLoaderWithFallbackComposite(
//                primary: localImageLoader,
//                fallback: FeedImageDataLoaderCacheDecorator(
//                    decoratee: remoteImageLoader,
//                    cache: localImageLoader
//                )
//            )
//        )
//
//        window?.rootViewController = feedViewController
//        window?.makeKeyAndVisible()
    }
}

