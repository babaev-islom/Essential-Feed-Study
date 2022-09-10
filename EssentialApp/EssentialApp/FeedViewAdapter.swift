//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Islom Babaev on 18/08/22.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { feedImage in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: feedImage, imageLoader: imageLoader)
            let cellController = FeedImageCellController(loadImageData: adapter.loadImageData, cancelImageDataLoad: adapter.cancelImageDataLoad)
            let presenter = FeedImagePresenter(view: WeakRefVirtualProxy(cellController), imageTransformer: UIImage.init)
            adapter.presenter = presenter
            return cellController
        })
    }
}
