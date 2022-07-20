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
    private var loadFeed: () -> Void

    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
    
    @objc
    func refresh() {
        self.loadFeed()
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
