//
//  MovieCellViewModel.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import UIKit

class MovieCellViewModel {
    typealias Observer<T> = ( (T) -> Void)
    
    private let movie: Movie
    private let imageLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    
    var movieID: Int {
        movie.id
    }
    
    var posterURL: URL? {
        let url = URL(string: "\(ROOT_IMAGE)w500/\(self.movie.poster_path)")
        return url
    }
    
    var title: String {
        movie.title
    }
    
    var overview: String {
        movie.overview
    }
    
    internal init(movie: Movie, imageLoader: ImageDataLoader) {
        self.movie = movie
        self.imageLoader = imageLoader
    }
    
    func loadImageData() {
        if let url = posterURL {
            self.onImageLoadingStateChange?(false)
            self.task = self.imageLoader.loadImageData(from: url) { result in
                let data = try? result.get()
                DispatchQueue.main.async {
                    self.onImageLoad?(data.flatMap(UIImage.init) ?? .init())
                    self.onImageLoadingStateChange?(true)
                }
            }
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
