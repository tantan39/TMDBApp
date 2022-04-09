//
//  ViewController.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import UIKit
import SDWebImage
import Resolver

protocol ImageDataLoader {
    func loadImageData(from url: URL)
    func cancelImageDataLoad(from url: URL)
}

enum Section {
    case movie
    case loadMore
}

class ViewController: UITableViewController {
    private lazy var datasource = UITableViewDiffableDataSource<Section, AnyHashable>(tableView: tableView) { tableView, indexPath, controller in
        switch controller {
        case let controller as MovieCellController:
            let cell = controller.view(in: tableView, forItemAt: indexPath)
            self.imageLoader.loadImageData(from: controller.posterURL)
            return cell
        case let loadMoreController as LoadMoreCellController:
            return loadMoreController.view(in: tableView, forItemAt: indexPath)
            
        default:
            return UITableViewCell()
        }
        
    }
    
    private var isLoadMore: Bool = false
    private var page: Int = 0
    @Injected var apiService: FeedLoader
    @Injected var imageLoader: ImageDataLoader

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        self.tableView.register(LoadMoreCell.self, forCellReuseIdentifier: "LoadMoreCell")
        fetchMovies()
    }

    private func set(_ newItems: [MovieCellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section,AnyHashable>()
        snapshot.appendSections([.movie, .loadMore])
        snapshot.appendItems(newItems, toSection: .movie)
        snapshot.appendItems([LoadMoreCellController()], toSection: .loadMore)
        self.datasource.apply(snapshot, animatingDifferences: false)
    }
    
    private func append(_ newItems: [MovieCellController]) {
        var snapshot = datasource.snapshot()
        snapshot.appendItems(newItems, toSection: .movie)
        self.datasource.apply(snapshot, animatingDifferences: true)
    }
    
    private func fetchMovies(_ page: Int = 1) {
        self.page = page
        apiService.fetchPopularMovies(page: page) { [weak self] result in
            guard let self = self else { return }
            self.isLoadMore = false
            switch result {
            case let .success(movies):
                let controllers = movies.map { MovieCellController(id: $0.id,
                                                                   title: $0.title,
                                                                   pathImage: $0.poster_path,
                                                                   description: $0.overview) }
                self.page == 1 ? self.set(controllers) : self.append(controllers)
                
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let controller = self.datasource.itemIdentifier(for: indexPath) as? MovieCellController else { return }
        imageLoader.cancelImageDataLoad(from: controller.posterURL)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? UITableView.automaticDimension : 40
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if (offsetY > contentHeight - scrollView.frame.height) && !self.isLoadMore {
            self.isLoadMore = true
            self.fetchMovies(self.page + 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = self.datasource.itemIdentifier(for: indexPath) as? MovieCellController else { return }
        self.navigationController?.pushViewController(MovieDetailVC(movieID: controller.id), animated: true)
    }
}

