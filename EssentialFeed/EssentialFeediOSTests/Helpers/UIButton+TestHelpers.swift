//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Islom Babaev on 16/08/22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
