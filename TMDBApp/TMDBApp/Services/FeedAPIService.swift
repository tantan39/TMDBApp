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
    let session = URLSession(configuration: .default)
    
    struct RootItem: Decodable {
        let page: Int
        let results: [Movie]
    }
    
    func fetchPopularMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let request = URL(string: Endpoint.popularMovies(page))!
        print(request.absoluteURL)
        session.dataTask(with: request) { data, response, error in
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
    
    func getMovieDetail(_ id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        let request = URL(string: Endpoint.details(id))!
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    if let movie = try? JSONDecoder().decode(Movie.self, from: data) {
                        completion(.success(movie))
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

private final class URLSessionTaskWrapper: ImageDataLoaderTask {
    var wrapped: URLSessionDataTask?
    
    func cancel() {
        wrapped?.cancel()
        wrapped = nil
    }
}

extension FeedAPIService: ImageDataLoader {
    
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataLoaderTask {
        let task = URLSessionTaskWrapper()
        
        task.wrapped = session.dataTask(with: url) { data, response, error in
            if let data = data {
                completion(.success(data))
            }
        }
        task.wrapped?.resume()

        return task
    }
}
