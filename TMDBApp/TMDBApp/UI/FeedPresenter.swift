//
//  FeedRefreshViewModel.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import Foundation
import Combine

protocol FeedView {
    func display(feed: [Movie])
}

protocol FeedLoadingView {
    func display(isLoading: Bool)
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
        self.loadingView?.display(isLoading: true)
        apiService.fetchPopularMovies(page: 1)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { error in
                
            }, receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.loadingView?.display(isLoading: false)
                self.feedView?.display(feed: movies)
            })
            .store(in: &cancellables)
    }
}
