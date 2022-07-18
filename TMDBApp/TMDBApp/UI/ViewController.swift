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
    private var loadMoreController: LoadMoreCellController?
    
    private var onSelected: ((Int) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    convenience init(refreshViewController: FeedRefreshViewController, loadMoreController: LoadMoreCellController, onSelected: ((Int) -> Void)? = { _ in }) {
        self.init()
        self.refreshViewController = refreshViewController
        self.loadMoreController = loadMoreController
        self.onSelected = onSelected
    }
    
    lazy var datasource = UITableViewDiffableDataSource<Section, AnyHashable>(tableView: tableView) { [weak self] tableView, indexPath, controller in
        switch controller {
        case let controller as MovieCellController:
            let cell = controller.view(in: tableView, forItemAt: indexPath)
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
        
        self.refreshViewController?.refresh()
    }

    func set(_ newItems: [MovieCellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section,AnyHashable>()
        snapshot.appendSections([.movie, .loadMore])
        snapshot.appendItems(newItems, toSection: .movie)
        snapshot.appendItems([loadMoreController], toSection: .loadMore)
        self.datasource.apply(snapshot, animatingDifferences: false)
    }
    
    func append(_ newItems: [MovieCellController]) {
        var snapshot = datasource.snapshot()
        snapshot.appendItems(newItems, toSection: .movie)
        self.datasource.apply(snapshot, animatingDifferences: true)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let controller = datasource.itemIdentifier(for: indexPath) as? LoadMoreCellController else { return }
        controller.loadMore()
    }
        
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard let controller = datasource.itemIdentifier(for: indexPath) as? MovieCellController else { return }
            controller.preload()
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { removeCellController(forRowAt: $0) }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let _ = datasource.itemIdentifier(for: indexPath) as? MovieCellController else { return 40 }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = self.datasource.itemIdentifier(for: indexPath) as? MovieCellController else { return }
        self.onSelected?(controller.movieID)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> MovieCellController? {
        guard let controller = datasource.itemIdentifier(for: indexPath) as? MovieCellController else { return nil }
        return controller
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        guard let controller = datasource.itemIdentifier(for: indexPath) as? MovieCellController else { return }
        controller.cancelLoad()
    }
}
