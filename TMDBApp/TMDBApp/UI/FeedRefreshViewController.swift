//
//  FeedRefreshViewController.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/16/22.
//

import Combine
import UIKit

class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    lazy var view: UIRefreshControl = loadView()
    private var presenter: FeedPresenter

    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    @objc
    func refresh() {
        self.presenter.loadFeed()
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
