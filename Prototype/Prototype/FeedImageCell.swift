//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Islom Babaev on 12/08/22.
//

import UIKit

final class FeedImageCell: UITableViewCell {
    
    @IBOutlet private(set) weak var locationContainer: UIStackView!
    @IBOutlet private(set) weak var locationLabel: UILabel!
    @IBOutlet private(set) weak var feedImageView: UIImageView!
    @IBOutlet private(set) weak var descriptionLabel: UILabel!
}
