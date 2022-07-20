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
    
    func display(feed: [Movie]) {
        let controllers = feed.map { MovieCellController(viewModel: MovieCellViewModel(movie: $0, imageLoader: loader, imageTransformer: UIImage.init)) }
        viewController?.set(controllers)
    }
}
