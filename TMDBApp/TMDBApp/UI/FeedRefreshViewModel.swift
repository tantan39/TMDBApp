//
//  FeedRefreshViewModel.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import Foundation
import Combine

class FeedRefreshViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var apiService: FeedLoader
    private var cancellables = Set<AnyCancellable>()
    var onLoadingStateChange: Observer<Bool> = { _ in }
    var onFeedLoad: Observer<[Movie]> = { _ in }
    
    init(apiService: FeedLoader) {
        self.apiService = apiService
    }
    
    func loadFeed() {
        self.onLoadingStateChange(true)
        apiService.fetchPopularMovies(page: 1)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { error in
                
            }, receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.onLoadingStateChange(false)
                self.onFeedLoad(movies)
            })
            .store(in: &cancellables)
    }
}
