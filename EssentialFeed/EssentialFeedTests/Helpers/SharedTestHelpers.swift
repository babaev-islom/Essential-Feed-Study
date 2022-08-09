//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 05/08/22.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}
