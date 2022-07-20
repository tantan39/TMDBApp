//
//  FeedRefreshViewModel.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import Foundation

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
        
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func didStartLoadingFeed() {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(_ feed: [Movie]) {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        self.feedView?.display(FeedViewModel(feed: feed))
    }
    
    func didFinishLoadingFeed(_ error: Error) {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}
