//
//  ImageDataLoader.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/9/22.
//

import Foundation

protocol ImageDataLoaderTask {
    func cancel()
}
protocol ImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataLoaderTask
}
