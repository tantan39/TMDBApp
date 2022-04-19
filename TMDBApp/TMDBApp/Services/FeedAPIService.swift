//
//  FeedAPIService.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/8/22.
//

import Foundation
import Combine

class FeedAPIService: FeedLoader {
    private let httpClient: HTTPClient
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    private struct RootItem: Decodable {
        let page: Int
        let results: [Movie]
    }
    
    func fetchPopularMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        let url = URL(string: Endpoint.popularMovies(page))!
        
        print(url.absoluteURL)
//        httpClient.get(url: url) { response in
//            switch response {
//            case let .success(data):
//                DispatchQueue.main.async {
//                    if let root = try? JSONDecoder().decode(RootItem.self, from: data) {
//                        completion(.success(root.results))
//                    } else {
//                        completion(.failure(.invalidData))
//                    }
//                }
//            case .failure:
//                completion(.failure(.connectionError))
//            }
//        }
        
        return Deferred {
            Future() { promise in
                self.httpClient.get(url: url) { response in
                    switch response {
                    case let .success(data):
                        if let root = try? JSONDecoder().decode(RootItem.self, from: data) {
                            promise(.success(root.results))
                        } else {
                            promise(.failure(.invalidData))
                        }
                    case .failure:
                        promise(.failure(.invalidData))
                    }
                }
            }
        }
        .eraseToAnyPublisher()

    }
    
    func getMovieDetail(_ id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        let request = URL(string: Endpoint.details(id))!
        httpClient.get(url: request) { response in
            switch response {
            case let .success(data):
                DispatchQueue.main.async {
                    if let movie = try? JSONDecoder().decode(Movie.self, from: data) {
                        completion(.success(movie))
                    } else {
                        completion(.failure(.invalidData))
                    }
                }
            default:
                completion(.failure(.connectionError))
            }
        }
    }
}

extension FeedAPIService: ImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataLoaderTask {
        let task = URLSessionTaskWrapper()
        
        task.wrapped = URLSession(configuration: .default).dataTask(with: url) { data, response, error in
            if let data = data {
                completion(.success(data))
            }
        }
        task.wrapped?.resume()
        
        return task
    }
}

private final class URLSessionTaskWrapper: ImageDataLoaderTask {
    var wrapped: URLSessionDataTask?
    
    func cancel() {
        wrapped?.cancel()
        wrapped = nil
    }
}

