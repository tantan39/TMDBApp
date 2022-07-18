//
//  MovieCellViewModel.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import UIKit

class MovieCellViewModel<Image> {
    typealias Observer<T> = ( (T) -> Void)
    
    private let movie: Movie
    private let imageLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    private var imageTransformer: ((Data) -> Image?)
    
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
    
    internal init(movie: Movie, imageLoader: ImageDataLoader, imageTransformer: @escaping ((Data) -> Image?)) {
        self.movie = movie
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    func loadImageData() {
        if let url = posterURL {
            self.onImageLoadingStateChange?(false)
            self.task = self.imageLoader.loadImageData(from: url) { result in
                if let image = (try? result.get()).flatMap(self.imageTransformer) {
                    DispatchQueue.main.async {
                        self.onImageLoad?(image)
                        self.onImageLoadingStateChange?(true)
                    }
                }
            }
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
