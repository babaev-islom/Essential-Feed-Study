//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Islom Babaev on 16/08/22.
//

import UIKit
import EssentialFeed

public final class FeedImageCellController: NSObject {
    
    public typealias ResourceViewModel = UIImage
    
    private let viewModel: FeedImageViewModel
    private let loadImageData: () -> Void
    private let cancelImageDataLoad: () -> Void
    private var cell: FeedImageCell?
    
    public init(
        viewModel: FeedImageViewModel,
        loadImageData: @escaping () -> Void,
        cancelImageDataLoad: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.loadImageData = loadImageData
        self.cancelImageDataLoad = cancelImageDataLoad
    }
}

extension FeedImageCellController: CellController {
        
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = loadImageData
        loadImageData()
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        loadImageData()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
    
    private func cancelLoad() {
        releaseCellForReuse()
        cancelImageDataLoad()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }

}

extension FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = (viewModel.message == nil)
    }
}
