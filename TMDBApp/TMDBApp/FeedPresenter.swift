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
        
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    internal init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        self.loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [Movie]) {
        self.loadingView.display(FeedLoadingViewModel(isLoading: false))
        self.feedView.display(FeedViewModel(feed: feed))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        self.loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
