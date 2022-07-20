//
//  FeedViewAdapter.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/19/22.
//

import UIKit

class FeedViewAdapter: FeedView {
    private weak var viewController: ViewController?
    private var loader: ImageDataLoader
    
    internal init(controller: ViewController?, loader: ImageDataLoader) {
        self.viewController = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {

        let controllers = viewModel.feed.map { model -> MovieCellController in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<MovieCellController>, UIImage>(model: model, imageLoader: loader)
            let view = MovieCellController(delegate: adapter, movieID: model.id)
            adapter.presenter = MovieCellPresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        }
        viewController?.set(controllers)
    }
}
