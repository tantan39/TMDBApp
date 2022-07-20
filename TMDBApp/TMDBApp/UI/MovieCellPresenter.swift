//
//  MovieCellViewModel.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import UIKit

protocol MovieImageView {
    associatedtype Image
    
    func display(_ viewModel: MovieCellViewModel<Image>)
}

class MovieCellPresenter<View: MovieImageView, Image> where View.Image == Image {
    private let view: View
    private var imageTransformer: ((Data) -> Image?)
    
    internal init(view: View, imageTransformer: @escaping ((Data) -> Image?)) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImage(for model: Movie) {
        let url = URL(string: "\(ROOT_IMAGE)w500/\(model.poster_path)")
        view.display(MovieCellViewModel(movieID: model.id,
                                        posterURL: url,
                                        title: model.title,
                                        overview: model.overview,
                                        image: nil,
                                        isLoading: true))
    }
    
    private struct InvalidImageDataError: Swift.Error {}
    
    func didFinishLoadingImage(with data: Data, for model: Movie) {
        guard let image = imageTransformer(data) else { return didFinishLoadingImage(with: InvalidImageDataError(), for: model) }
        let url = URL(string: "\(ROOT_IMAGE)w500/\(model.poster_path)")
        view.display(MovieCellViewModel(movieID: model.id,
                                        posterURL: url,
                                        title: model.title,
                                        overview: model.overview,
                                        image: image,
                                        isLoading: false))
    }
    
    func didFinishLoadingImage(with error: Swift.Error, for model: Movie) {
        view.display(MovieCellViewModel(movieID: model.id,
                                        posterURL: nil,
                                        title: model.title,
                                        overview: model.overview,
                                        image: nil,
                                        isLoading: false))
    }
}
