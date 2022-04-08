//
//  FeedLoader.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import Foundation

protocol FeedLoader {
    func fetchPopularMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void)
}
