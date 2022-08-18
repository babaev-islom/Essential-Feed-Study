//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Islom Babaev on 18/08/22.
//

import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func loadImageData() {
        presenter?.didStartLoadingImageData(for: model)
        self.task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.presenter?.didFinishLoadingImageData(with: data, for: self.model)
            case let .failure(error):
                self.presenter?.didFinishLoadingImageData(with: error, for: self.model)
            }
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
    }
    
}
