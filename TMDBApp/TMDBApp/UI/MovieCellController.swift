//
//  MovieCellController.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import UIKit

class MovieCellController {
    private let viewModel: MovieCellViewModel
    
    var movieID: Int {
        viewModel.movieID
    }
    
    internal init(viewModel: MovieCellViewModel) {
        self.viewModel = viewModel
    }
    
    var posterURL: URL? {
        let url = viewModel.posterURL
        return url
    }
    
    func view(in tableView: UITableView) -> MovieCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as? MovieCell else { return MovieCell() }
        binding(cell)
        viewModel.loadImageData()
        return cell
    }
    
    func binding(_ cell: MovieCell) {
        cell.titleLabel.text = self.viewModel.title
        cell.descriptionLabel.text = self.viewModel.overview
        cell.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        cell.poster.image = nil
        cell.isShimmering = true
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.isShimmering = false
            cell?.poster.setImageAnimated(image)
        }
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
}

extension MovieCellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(viewModel.movieID)
    }

    static func == (lhs: MovieCellController,
                        rhs: MovieCellController) -> Bool {
        lhs.viewModel.movieID == rhs.viewModel.movieID
        }
}
