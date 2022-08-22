//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Islom Babaev on 22/08/22.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
