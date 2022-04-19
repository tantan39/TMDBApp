//
//  FeedLoader.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import Foundation
import Combine

protocol FeedLoader {
//    func fetchPopularMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void)
    func fetchPopularMovies(page: Int) -> AnyPublisher<[Movie], Error>
    func getMovieDetail(_ id: Int, completion: @escaping (Result<Movie, Error>) -> Void)
}
