//
//  FeedAPIServiceTests.swift
//  TMDBAppTests
//
//  Created by Tan Tan on 4/11/22.
//

import Foundation
import XCTest
@testable import TMDBApp

class FeedAPIServiceTests: XCTestCase {
    func test_fetchPopularMovies_responseJSONEmptyList() {
        let client = HTTPClientSpy()
        let sut = FeedAPIService(httpClient: client)
        
        let exp = expectation(description: "Wait for loading")
        sut.fetchPopularMovies(page: 1) { response in
            switch response {
            case let .success(items):
                XCTAssertTrue(items.isEmpty)
            case .failure:
                XCTFail("Failure")
            }
            exp.fulfill()
        }
        
        let emptyPage = makeMovie(items: [])
        let json = makeItemsJSONData(for: emptyPage.json)
        client.completeWith(data: json)
        wait(for: [exp], timeout: 2.0)
    }
    
    class HTTPClientSpy: HTTPClient {
        var completions: [(Result<Data, Swift.Error>) -> Void] = []

        func get(url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void) {
            completions.append(completion)
        }
        
        func completeWith(data: Data, index: Int = 0) {
            completions[index](.success(data))
        }
    }
    
    func makeMovie(items: [(model: Movie, json: [String : Any])] = [], page: Int = 1) -> (model: Movie, json: [String: Any]) {

      let model = Movie(id: 0,
                        title: "a title",
                        overview: "over view",
                        poster_path: "path", backdrop_path: nil, release_date: nil, revenue: nil)

      let json: [String: Any] = [
        "results": items.map { $0.json },
        "page": page
      ]

      return (model, json.compactMapValues { $0 })
    }
    
    private func makeItemsJSONData(for items: [String: Any]) -> Data {
      let data = try! JSONSerialization.data(withJSONObject: items)
      return data
    }
}
