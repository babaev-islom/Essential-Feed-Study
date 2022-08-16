//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Islom Babaev on 16/08/22.
//

import UIKit
import EssentialFeed

final class FeedImageCellController: FeedImageView {
    private var cell: FeedImageCell?
    
    private let loadImageData: () -> Void
    private let cancelImageDataLoad: () -> Void
    
    init(loadImageData: @escaping () -> Void, cancelImageDataLoad: @escaping () -> Void) {
        self.loadImageData = loadImageData
        self.cancelImageDataLoad = cancelImageDataLoad
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        loadImageData()
        return cell!
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = loadImageData
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.feedImageView.image = viewModel.image
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    func preload() {
        loadImageData()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        cancelImageDataLoad()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

