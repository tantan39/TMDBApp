//
//  ViewController.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import UIKit
import SDWebImage

class ViewController: UITableViewController {

    lazy var datasource = UITableViewDiffableDataSource<Int, MovieCellController>(tableView: tableView) { tableView, indexPath, controller in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as? MovieCell else { return UITableViewCell() }
        cell.titleLabel.text = controller.title
        cell.descriptionLabel.text = controller.description
        cell.poster.sd_setImage(with: controller.posterURL, placeholderImage: UIImage(named: "placeHolder"))
        cell.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        fetchMovies()
    }

    func fetchMovies() {
        let apiService = FeedAPIService()
        apiService.fetchPopularMovies(page: 1) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(movies):
                let controllers = movies.map { MovieCellController(id: $0.id, title: $0.title, pathImage: $0.poster_path, description: $0.overview) }
                var snapshot = NSDiffableDataSourceSnapshot<Int,MovieCellController>()
                snapshot.appendSections([0])
                snapshot.appendItems(controllers, toSection: 0)
                self.datasource.apply(snapshot)
                
            default:
                break
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

