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

public struct LoadMoreCellController {
    let id: AnyHashable
    let isLoading: Bool
}

extension LoadMoreCellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class LoadMoreCell: UITableViewCell {
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false

        return spinner
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupUI()
    }
    
    private func setupUI() {
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            spinner.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

class ViewController: UITableViewController {

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
            cell.spinner.startAnimating()
            cell.backgroundColor = .yellow
            return cell
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        self.tableView.register(LoadMoreCell.self, forCellReuseIdentifier: "LoadMoreCell")
        fetchMovies()
    }

    func fetchMovies() {
        let apiService = FeedAPIService()
        apiService.fetchPopularMovies(page: 1) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(movies):
                let controllers = movies.map { MovieCellController(id: $0.id, title: $0.title, pathImage: $0.poster_path, description: $0.overview) }
                var snapshot = NSDiffableDataSourceSnapshot<Section,AnyHashable>()
                snapshot.appendSections([.movie, .loadMore])
                snapshot.appendItems(controllers, toSection: .movie)
                snapshot.appendItems([LoadMoreCellController(id: UUID(), isLoading: true)], toSection: .loadMore)
                
                self.datasource.apply(snapshot)
                
            default:
                break
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.section == 0 ? UITableView.automaticDimension : 40
    }
}

