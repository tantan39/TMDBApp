//
//  FeedAPIService.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/8/22.
//

import Foundation

enum APIError: Error {
    case invalidData
    case connectionError
}

class FeedAPIService: FeedLoader {
    struct RootItem: Decodable {
        let page: Int
        let results: [Movie]
    }
    
    func fetchPopularMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let request = URL(string: Endpoint.popularMovies(page))!
        print(request.absoluteURL)
        URLSession(configuration: .default).dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    if let root = try? JSONDecoder().decode(RootItem.self, from: data) {
                        completion(.success(root.results))
                    } else {
                        completion(.failure(APIError.invalidData))
                    }
                } else {
                    completion(.failure(APIError.connectionError))
                }
            }
        }
        .resume()
    }
}