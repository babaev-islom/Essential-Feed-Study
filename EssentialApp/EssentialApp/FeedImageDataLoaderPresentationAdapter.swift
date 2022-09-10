//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Islom Babaev on 18/08/22.
//

//import Combine
//import Foundation
//import EssentialFeed
//
//final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
//    private let model: FeedImage
//    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
//    private var cancellable: AnyCancellable?
//    
//    var presenter: FeedImagePresenter<View, Image>?
//    
//    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
//        self.model = model
//        self.imageLoader = imageLoader
//    }
//    
//    func loadImageData() {
//        presenter?.didStartLoadingImageData(for: model)
//        
//        let model = self.model
//        
//        cancellable = imageLoader(model.url)
//            .sink { [weak self] completion in
//                switch completion {
//                case .finished: break
//                case let .failure(error):
//                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
//                }
//            } receiveValue: { [weak self] data in
//                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
//            }
//    }
//    
//    func cancelImageDataLoad() {
//        cancellable?.cancel()
//    }
//    
//}
