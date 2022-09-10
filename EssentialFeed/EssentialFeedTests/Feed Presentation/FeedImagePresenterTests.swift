//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 22/08/22.
//

import XCTest
import EssentialFeed


final class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let image = uniqueImage()
        
        let viewModel = FeedImagePresenter<ViewSpy, String>.map(image)
        
        XCTAssertEqual(viewModel.description, image.description )
        XCTAssertEqual(viewModel.location, image.location)
    }
    
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
        let anyImage = "any image"
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
    
    func test_didFinishLoadingImageDataWithData_displaysNoImage_stopsLoading_andShouldRetry() {
        let (sut, view) = makeSUT(imageTransformer: { _ in nil })
        let model = uniqueImageFeed().models.first!
        
        sut.didFinishLoadingImageData(with: Data(), for: model)
        
        XCTAssertEqual(view.messages, [
            .display(location: model.location),
            .display(description: model.description),
            .display(image: nil),
            .display(isLoading: false),
            .display(shouldRetry: true)
        ])
    }
    
    func test_didFinishLoadingImageDataWithError_displaysNoImageAndShouldRetry() {
        let (sut, view) = makeSUT()
        let model = uniqueImageFeed().models.first!
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: model)
        
        XCTAssertEqual(view.messages, [
            .display(location: model.location),
            .display(description: model.description),
            .display(image: nil),
            .display(isLoading: false),
            .display(shouldRetry: true)
        ])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> String? = { _ in "" }, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, String>, view: ViewSpy) {
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
            case display(image: String?)
            case display(isLoading: Bool)
            case display(shouldRetry: Bool)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedImageViewModel<String>) {
            messages.insert(.display(location: viewModel.location))
            messages.insert(.display(description: viewModel.description))
            messages.insert(.display(image: viewModel.image))
            messages.insert(.display(isLoading: viewModel.isLoading))
            messages.insert(.display(shouldRetry: viewModel.shouldRetry))
        }
    }
}
