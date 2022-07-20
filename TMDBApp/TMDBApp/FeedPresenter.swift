//
//  FeedRefreshViewModel.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import Foundation
import Combine

struct FeedViewModel {
    var feed: [Movie]
}

struct FeedLoadingViewModel {
    var isLoading: Bool
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private var apiService: FeedLoader
    private var cancellables = Set<AnyCancellable>()
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    init(apiService: FeedLoader) {
        self.apiService = apiService
    }
    
    func loadFeed() {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: true))
        apiService.fetchPopularMovies(page: 1)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { error in
                
            }, receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.loadingView?.display(FeedLoadingViewModel(isLoading: false))
                self.feedView?.display(FeedViewModel(feed: movies))
            })
            .store(in: &cancellables)
    }
}
