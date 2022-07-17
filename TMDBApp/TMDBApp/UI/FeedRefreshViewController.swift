//
//  FeedRefreshViewController.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/16/22.
//

import Combine
import UIKit

class FeedRefreshViewController: NSObject {
    
    lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    private var apiService: FeedLoader
    private var cancellables = Set<AnyCancellable>()
    var onRefresh: ([Movie]) -> Void = { _ in }
    
    init(apiService: FeedLoader) {
        self.apiService = apiService
    }
    
    @objc
    func refresh() {
        self.view.beginRefreshing()
        apiService.fetchPopularMovies(page: 1)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { error in
                
            }, receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.view.endRefreshing()
                self.onRefresh(movies)
            })
            .store(in: &cancellables)
    }
}
