//
//  ViewController.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import UIKit
import Combine

enum Section: Int {
    case movie
    case loadMore
}

class ViewController: UITableViewController, UITableViewDataSourcePrefetching {

    private var refreshViewController: FeedRefreshViewController?
    private var isLoadMore: Bool = false
    private var page: Int = 1
    private var tasks = [IndexPath: ImageDataLoaderTask]()
    
    private var apiService: FeedLoader?
    private var imageLoader: ImageDataLoader?
    private var onSelected: ((Int) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    convenience init(apiService: FeedLoader, imageLoader: ImageDataLoader, onSelected: ((Int) -> Void)? = { _ in }) {
        self.init()
        self.apiService = apiService
        self.imageLoader = imageLoader
        self.refreshViewController = FeedRefreshViewController(apiService: apiService)
        self.onSelected = onSelected
    }
    
    lazy var datasource = UITableViewDiffableDataSource<Section, AnyHashable>(tableView: tableView) { [weak self] tableView, indexPath, controller in
        switch controller {
        case let controller as MovieCellController:
            let cell = controller.view(in: tableView, forItemAt: indexPath)
            cell.poster.image = nil
            cell.isShimmering = true
            if let url = controller.posterURL {
                self?.tasks[indexPath] = self?.imageLoader?.loadImageData(from: url) { [weak cell] result in
                    let data = try? result.get()
                    DispatchQueue.main.async { [weak self] in
                        cell?.isShimmering = false
                        cell?.poster.setImageAnimated(data.map(UIImage.init) ?? nil)
                    }
                }
            }
            return cell
            
        case let loadMoreController as LoadMoreCellController:
            return loadMoreController.view(in: tableView, forItemAt: indexPath)
            
        default:
            return UITableViewCell()
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Popular"
        self.refreshControl = refreshViewController?.view
        self.tableView.prefetchDataSource = self
        self.tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        self.tableView.register(LoadMoreCell.self, forCellReuseIdentifier: "LoadMoreCell")
        
        self.refreshViewController?.onRefresh = { [weak self] movies in
            let controllers = movies.map { MovieCellController(id: $0.id,
                                                               title: $0.title,
                                                               pathImage: $0.poster_path,
                                                               description: $0.overview) }
            self?.set(controllers)
        }
        self.refreshViewController?.refresh()
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
    
    @objc
    private func fetchMovies(_ page: Int = 1) {
        self.page = page
        
        apiService?.fetchPopularMovies(page: page)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { error in
            }, receiveValue: { [weak self] movies in
                guard let self = self else { return }
                let controllers = movies.map { MovieCellController(id: $0.id,
                                                                   title: $0.title,
                                                                   pathImage: $0.poster_path,
                                                                   description: $0.overview) }
                self.page == 1 ? self.set(controllers) : self.append(controllers)
            })
            .store(in: &cancellables)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let controller = datasource.itemIdentifier(for: indexPath) as? MovieCellController, let url = controller.posterURL else { return }
        tasks[indexPath] = imageLoader?.loadImageData(from: url, completion: { _ in })
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard let controller = datasource.itemIdentifier(for: indexPath) as? MovieCellController, let url = controller.posterURL else { return }
            tasks[indexPath] = imageLoader?.loadImageData(from: url, completion: { _ in })
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            tasks[indexPath]?.cancel()
            tasks[indexPath] = nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let _ = datasource.itemIdentifier(for: indexPath) as? MovieCellController else { return 40 }
        return UITableView.automaticDimension
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
        self.onSelected?(controller.id)
    }
}
