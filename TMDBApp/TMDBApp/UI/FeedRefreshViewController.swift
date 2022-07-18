//
//  FeedRefreshViewController.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/16/22.
//

import Combine
import UIKit

class FeedRefreshViewController: NSObject {
    
    lazy var view: UIRefreshControl = binding(UIRefreshControl())
    private var viewModel: FeedRefreshViewModel

    init(viewModel: FeedRefreshViewModel) {
        self.viewModel = viewModel
    }
    
    @objc
    func refresh() {
        self.viewModel.loadFeed()
    }
    
    private func binding(_ view: UIRefreshControl) -> UIRefreshControl {
        self.viewModel.onLoadingStateChange = { [weak self] isLoading in
            isLoading ? self?.view.beginRefreshing() : self?.view.endRefreshing()
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
