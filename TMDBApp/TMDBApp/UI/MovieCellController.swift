//
//  MovieCellController.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import UIKit

protocol MovieCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

class MovieCellController: MovieImageView {
    private let delegate: MovieCellControllerDelegate?
    var cell: MovieCell?
    let movieID: Int
    
    internal init(delegate: MovieCellControllerDelegate, movieID: Int) {
        self.delegate = delegate
        self.movieID = movieID
    }
    
    func view(in tableView: UITableView) -> MovieCell {
        cell = MovieCell()
        self.delegate?.didRequestImage()
        return cell ?? MovieCell()
    }
    
    func display(_ viewModel: MovieCellViewModel<UIImage>) {
        cell?.titleLabel.text = viewModel.title
        cell?.descriptionLabel.text = viewModel.overview
        cell?.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        cell?.poster.setImageAnimated(viewModel.image)
        cell?.isShimmering = viewModel.isLoading
    }
    
    func preload() {
        delegate?.didRequestImage()
    }
    
    func cancelLoad() {
        delegate?.didCancelImageRequest()
    }
}

extension MovieCellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.movieID)
    }

    static func == (lhs: MovieCellController,
                    rhs: MovieCellController) -> Bool {
        lhs.movieID == rhs.movieID
    }
}
