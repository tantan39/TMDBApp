//
//  ViewControllerTests.swift
//  TMDBAppTests
//
//  Created by Tan Tan on 4/10/22.
//

import XCTest
@testable import TMDBApp
class ViewControllerTests: XCTestCase {

    func test_init_emptyList() {
        let (viewController, _) = makeSUT()
        let snapshot = viewController.datasource.snapshot()
        XCTAssertEqual(snapshot.numberOfSections, 0)
        XCTAssertEqual(snapshot.numberOfItems, 0)
    }
    
    func test_viewDidLoad_fetchMovies() {
        let (viewController, loader) = makeSUT()
        let movies = [
            makeMovieItem(id: 0),
            makeMovieItem(id: 1, title: "another title", overView: "another overview")
        ]
        
        viewController.loadViewIfNeeded()
        loader.complete(with: movies, at: 0)
        
        let snapshot = viewController.datasource.snapshot()
        XCTAssertEqual(snapshot.numberOfSections, 2)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .movie), movies.count)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .loadMore), 1)
    }
    
    func test_fetchMovies_renderingCells() throws {
        let (viewController, loader) = makeSUT()
        let movies = [
            makeMovieItem(id: 0),
            makeMovieItem(id: 1, title: "another title", overView: "another overview")
        ]
        
        viewController.loadViewIfNeeded()
        loader.complete(with: movies, at: 0)
        let snapshot = viewController.datasource.snapshot()
        for (index, item) in movies.enumerated() {
            let controller = try XCTUnwrap(snapshot.itemIdentifiers(inSection: .movie)[index] as? MovieCellController)
            
            XCTAssertEqual(controller.title, item.title)
            XCTAssertEqual(controller.description, item.overview)
            XCTAssertEqual(controller.pathImage, item.poster_path)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: ViewController, loader: FeedServiceSpy) {
        let loader = FeedServiceSpy()
        let feedService = FeedAPIService()
        let viewController = ViewController(apiService: loader, imageLoader: feedService)
        return (viewController, loader)
    }
    
    private func makeMovieItem(id: Int, title: String = "a movie title", overView: String = "a overview") -> Movie {
        Movie(id: id, title: "a movie title", overview: "a overview", poster_path: "poster path", backdrop_path: nil, release_date: nil, revenue: nil)

    }
    
    private class FeedServiceSpy: FeedLoader {
        var messages: [(Result<[Movie], Error>) -> Void] = []
        
        func fetchPopularMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
            messages.append(completion)
        }
        
        func complete(with items: [Movie], at index: Int = 0) {
            messages[index](.success(items))
        }
        
        func getMovieDetail(_ id: Int, completion: @escaping (Result<Movie, Error>) -> Void) { }
    }
    
    
}

extension ViewController {
    func cellForRowAt(row: Int, section: Section) -> UITableViewCell? {
        tableView.cellForRow(at: IndexPath(row: row, section: section.hashValue))
    }
}