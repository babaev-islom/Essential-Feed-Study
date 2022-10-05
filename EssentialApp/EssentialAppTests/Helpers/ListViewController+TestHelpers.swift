//
//  ListViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Islom Babaev on 16/08/22.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    func simulateTapOnErrorMessage() {
        errorView.simulateTap()
    }

}
    
extension ListViewController {
    func numberOfRenderedComments() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
    }
    
    private var commentsSection: Int {
        return 0
    }
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }
    
    private func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedComments() > row else { return nil }
        
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }

}

extension ListViewController {
    
    func simulateLoadMoreFeedAction() {
        guard let view = cell(row: 0, section: feedLoadMoreSection) else { return }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
    }
    
    private func cell(row: Int, section: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return dataSource?.tableView(tableView, cellForRowAt: index)
    }
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        simulateFeedImageViewVisible(at: 0)?.renderedImage
    }
    
    func numberOfRenderedImageViews() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        return 0
    }
    
    private var feedLoadMoreSection: Int {
        return 1
    }

    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedImageViews() > row else { return nil }
        
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}
