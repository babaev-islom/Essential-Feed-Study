//
//  UItableView+dequeueing.swift
//  EssentialFeediOS
//
//  Created by Islom Babaev on 16/08/22.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
