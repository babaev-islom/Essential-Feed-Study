//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Islom Babaev on 22/08/22.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
