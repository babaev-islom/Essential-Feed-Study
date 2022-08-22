//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 22/08/22.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel<Image> {
    let location: String?
    let description: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}


final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            fatalError()
        }

        view.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: image,
                isLoading: false,
                shouldRetry: false
            )
        )
    }
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotMessageViewsUponCreation() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_displaysFeedImageViewModelWithNoImageAndStartsLoading() {
        let (sut, view) = makeSUT()
        let model = uniqueImageFeed().models.first!
        
        sut.didStartLoadingImageData(for: model)
        
        XCTAssertEqual(view.messages, [
            .display(location: model.location),
            .display(description: model.description),
            .display(image: nil),
            .display(isLoading: true),
            .display(shouldRetry: false)
        ])
    }
    
    func test_didFinishLoadingImageDataWithData_displaysImageAndStopsLoading() {
        let anyImage = UIImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in anyImage })
        let model = uniqueImageFeed().models.first!
        
        sut.didFinishLoadingImageData(with: Data(), for: model)
        
        XCTAssertEqual(view.messages, [
            .display(location: model.location),
            .display(description: model.description),
            .display(image: anyImage),
            .display(isLoading: false),
            .display(shouldRetry: false)
        ])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> UIImage? = { _ in UIImage() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, UIImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }
    
    private final class ViewSpy: FeedImageView {
        enum Message: Hashable {
            case display(location: String?)
            case display(description: String?)
            case display(image: UIImage?)
            case display(isLoading: Bool)
            case display(shouldRetry: Bool)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedImageViewModel<UIImage>) {
            messages.insert(.display(location: viewModel.location))
            messages.insert(.display(description: viewModel.description))
            messages.insert(.display(image: viewModel.image))
            messages.insert(.display(isLoading: viewModel.isLoading))
            messages.insert(.display(shouldRetry: viewModel.shouldRetry))
        }
    }
}
