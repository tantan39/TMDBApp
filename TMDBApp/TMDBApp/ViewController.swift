//
//  ViewController.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import UIKit
import SDWebImage

enum Section {
    case movie
    case loadMore
}

class ViewController: UITableViewController {
    var page: Int = 0
    
    lazy var datasource = UITableViewDiffableDataSource<Section, AnyHashable>(tableView: tableView) { tableView, indexPath, item in
        switch item {
        case let item as MovieCellController:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as? MovieCell else { return UITableViewCell() }
            cell.titleLabel.text = item.title
            cell.descriptionLabel.text = item.description
            cell.poster.sd_setImage(with: item.posterURL, placeholderImage: UIImage(named: "placeHolder"))
            cell.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
            return cell
            
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell") as? LoadMoreCell else { return UITableViewCell() }
            return cell
        }
        
    }
    
    var controllers: [MovieCellController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        self.tableView.register(LoadMoreCell.self, forCellReuseIdentifier: "LoadMoreCell")
        fetchMovies()
    }

    var isLoadMore: Bool = false
    func fetchMovies(_ page: Int = 0) {
        self.page += 1
        
        let apiService = FeedAPIService()
        apiService.fetchPopularMovies(page: self.page) { [weak self] result in
            guard let self = self else { return }
            self.isLoadMore = false
            switch result {
            case let .success(movies):
                let controllers = movies.map { MovieCellController(id: $0.id, title: $0.title, pathImage: $0.poster_path, description: $0.overview) }
                self.controllers.append(contentsOf: controllers)
                var snapshot = NSDiffableDataSourceSnapshot<Section,AnyHashable>()
                snapshot.appendSections([.movie, .loadMore])
                snapshot.appendItems(self.controllers, toSection: .movie)
                snapshot.appendItems([LoadMoreCellController()], toSection: .loadMore)
                
                self.datasource.apply(snapshot)
                
            default:
                break
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? UITableView.automaticDimension : 40
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is LoadMoreCell && !self.isLoadMore {
            self.isLoadMore = true
            fetchMovies(self.page)
        }
    }
}

