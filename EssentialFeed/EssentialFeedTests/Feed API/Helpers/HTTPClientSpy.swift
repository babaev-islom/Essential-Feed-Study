//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 22/08/22.
//

import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
   private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
   var requestedURLs: [URL] {
       messages.map(\.url)
   }
   
   private(set) var cancelledURLs = [URL]()
   
   private struct TaskSpy: HTTPClientTask {
       let callback: () -> Void
       
       func cancel() {
           callback()
       }
   }
   
   func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
       messages.append((url, completion))
       return TaskSpy { [weak self] in self?.cancelledURLs.append(url) }
   }
   
   func complete(with error: NSError, at index: Int = 0) {
       messages[index].completion(.failure(error))
   }
   
   func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
       let message = messages[index]
       let url = message.url
       let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
       message.completion(.success((data, response)))
   }
}
