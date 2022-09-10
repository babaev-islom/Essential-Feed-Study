//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Islom Babaev on 16/08/22.
//

import UIKit
import EssentialFeed

public final class FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView, CellController {
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
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = loadImageData
        loadImageData()
        return cell!
    }
        
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = (viewModel.message == nil)
    }
    
    public func preload() {
        loadImageData()
    }
    
    public func cancelLoad() {
        releaseCellForReuse()
        cancelImageDataLoad()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
