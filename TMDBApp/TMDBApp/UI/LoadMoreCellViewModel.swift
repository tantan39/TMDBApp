//
//  LoadMoreCellViewModel.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import Foundation
import Combine

class LoadMoreCellViewModel {
    typealias Observer<T> = (T) -> Void
        
    private var page: Int = 1
    private var isLoadMore: Bool = false
    private var apiService: FeedLoader
    private var cancellables = Set<AnyCancellable>()
    var onPaging: Observer<[Movie]>?
    
    internal init(apiService: FeedLoader) {
        self.apiService = apiService
    }
    
    func loadMore() {
        guard !isLoadMore else { return }
        isLoadMore = true
        self.page += 1
        
        apiService.fetchPopularMovies(page: page)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { error in
            }, receiveValue: { [weak self] movies in
                self?.isLoadMore = false
                self?.onPaging?(movies)
            })
            .store(in: &cancellables)
    }
}
