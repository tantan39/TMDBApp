//
//  FeedRefreshViewController.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/16/22.
//

import Combine
import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestRefresh()
}

class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    lazy var view: UIRefreshControl = loadView()
    
    private let delegate: FeedRefreshViewControllerDelegate

    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc
    func refresh() {
        self.delegate.didRequestRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }
}
