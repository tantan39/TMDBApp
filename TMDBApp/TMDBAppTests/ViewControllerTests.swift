//
//  ViewControllerTests.swift
//  TMDBAppTests
//
//  Created by Tan Tan on 4/10/22.
//

import XCTest
import Combine
@testable import TMDBApp
class ViewControllerTests: XCTestCase {

    func test_init_emptyList() {
        let (sut, _) = makeSUT()
        let snapshot = sut.datasource.snapshot()
        XCTAssertEqual(snapshot.numberOfSections, 0)
        XCTAssertEqual(snapshot.numberOfItems, 0)
    }
    
    func test_viewDidLoad_fetchMovies() {
        let (sut, loader) = makeSUT()
        let movies = [
            makeMovieItem(id: 0),
            makeMovieItem(id: 1, title: "another title", overView: "another overview")
        ]

        sut.loadViewIfNeeded()
        loader.complete(with: movies, at: 0)

        let snapshot = sut.datasource.snapshot()
        XCTAssertEqual(snapshot.numberOfSections, 2)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .movie), movies.count)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .loadMore), 1)
    }
    
    func test_refresh_successDeliverEmpty() {
        let (sut, loader) = makeSUT()
        let movies = [
            makeMovieItem(id: 0),
            makeMovieItem(id: 1, title: "another title", overView: "another overview")
        ]

        sut.loadViewIfNeeded()
        loader.complete(with: movies, at: 0)
        
        sut.simulatePullToRefresh()
        loader.complete(with: [], at: 1)

        let snapshot = sut.datasource.snapshot()
        XCTAssertEqual(snapshot.numberOfSections, 2)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .movie), 0)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .loadMore), 1)
    }
    
    func test_refresh_successDeliverMovies() {
        let (sut, loader) = makeSUT()
        let movies = [
            makeMovieItem(id: 0),
            makeMovieItem(id: 1, title: "another title", overView: "another overview")
        ]

        sut.loadViewIfNeeded()
        loader.complete(with: [], at: 0)
        
        sut.simulatePullToRefresh()
        loader.complete(with: movies, at: 1)

        let snapshot = sut.datasource.snapshot()
        XCTAssertEqual(snapshot.numberOfSections, 2)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .movie), movies.count)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .loadMore), 1)
    }

    func test_fetchMovies_renderingCells() throws {
        let (sut, loader) = makeSUT()
        let movies = [
            makeMovieItem(id: 0),
            makeMovieItem(id: 1, title: "another title", overView: "another overview")
        ]

        sut.loadViewIfNeeded()
        loader.complete(with: movies, at: 0)

        let snapshot = sut.datasource.snapshot()
        for (index, item) in movies.enumerated() {
            let controller = try XCTUnwrap(snapshot.itemIdentifiers(inSection: .movie)[index] as? MovieCellController)

//            let cell = controller.view(in: sut.tableView, forItemAt: IndexPath(row: index, section: 0))
            let cell = controller.view(in: sut.tableView)

//            XCTAssertEqual(controller.title, item.title)
//            XCTAssertEqual(controller.description, item.overview)
//            XCTAssertEqual(controller.pathImage, item.poster_path)

            XCTAssertEqual(cell.titleLabel.text, item.title)
            XCTAssertEqual(cell.descriptionLabel.text, item.overview)
        }
    }

    func test_fetchMovies_failure_renderingEmpty() throws {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeWithError(.invalidData, at: 0)

        let snapshot = sut.datasource.snapshot()
        XCTAssertEqual(snapshot.numberOfItems, 0)
        XCTAssertEqual(snapshot.numberOfSections, 0)
    }

    func test_scrollToLastItem_renderingLoadMoreCell() throws {
        let (sut, loader) = makeSUT()
        let movies = [
            makeMovieItem(id: 0),
            makeMovieItem(id: 1, title: "another title", overView: "another overview")
        ]

        sut.loadViewIfNeeded()
        loader.complete(with: movies, at: 0)
        sut.simulateLoadMore()

        let _ = try XCTUnwrap(sut.simulateItemVisible(at: 0, section: .loadMore) as? LoadMoreCell)
    }

    func test_tableView_loadMoreSuccess_responseListItem() throws {
        let (sut, loader) = makeSUT()
        var movies = [
            makeMovieItem(id: 0),
            makeMovieItem(id: 1, title: "another title", overView: "another overview")
        ]

        sut.loadViewIfNeeded()
        loader.complete(with: movies)

        sut.simulateLoadMore()
        let nextPageItem = makeMovieItem(id: 2)
        loader.complete(with: [nextPageItem], at: 1)
        movies.append(nextPageItem)

        let snapshot = sut.datasource.snapshot()
        XCTAssertEqual(snapshot.numberOfItems(inSection: .movie), movies.count)

        for (index, item) in movies.enumerated() {
            let controller = try XCTUnwrap(snapshot.itemIdentifiers(inSection: .movie)[index] as? MovieCellController)

            let cell = controller.view(in: sut.tableView)

            XCTAssertEqual(cell.titleLabel.text, item.title)
            XCTAssertEqual(cell.descriptionLabel.text, item.overview)
        }
    }

    func test_tableView_loadMoreSuccess_reponseEmptyList() throws {
        let (sut, loader) = makeSUT()
        var movies = [
            makeMovieItem(id: 0),
            makeMovieItem(id: 1, title: "another title", overView: "another overview")
        ]

        sut.loadViewIfNeeded()
        loader.complete(with: movies)

        sut.simulateLoadMore()
        let nextPageItems: [Movie] = []
        loader.complete(with: nextPageItems)
        movies.append(contentsOf: nextPageItems)

        let snapshot = sut.datasource.snapshot()
        XCTAssertEqual(snapshot.numberOfItems(inSection: .movie), movies.count)

        for (index, item) in movies.enumerated() {
            let controller = try XCTUnwrap(snapshot.itemIdentifiers(inSection: .movie)[index] as? MovieCellController)

            let cell = controller.view(in: sut.tableView)

            XCTAssertEqual(cell.titleLabel.text, item.title)
            XCTAssertEqual(cell.descriptionLabel.text, item.overview)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ViewController, loader: FeedServiceSpy) {
        let loader = FeedServiceSpy()
        
        let adapter = FeedLoaderPresentationAdapter(loader: loader)
        let refreshViewController = FeedRefreshViewController(delegate: adapter)
        let loadMoreViewModel = LoadMoreCellViewModel(apiService: loader)
        let loadMoreController = LoadMoreCellController(viewModel: loadMoreViewModel)
        let viewController = ViewController(refreshViewController: refreshViewController, loadMoreController: loadMoreController)
        adapter.presenter = FeedPresenter(feedView: FeedViewAdapter(controller: viewController, loader: loader), loadingView: refreshViewController)
        
        loadMoreViewModel.onPaging = { [weak viewController] feed in
            let controllers = feed.map { model -> MovieCellController in
                let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<MovieCellController>, UIImage>(model: model, imageLoader: loader)
                let view = MovieCellController(delegate: adapter, movieID: model.id)
                adapter.presenter = MovieCellPresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
                return view
            }
            viewController?.append(controllers)
        }
        
        trackMemoryLeaks(viewController, file: file, line: line)
        return (viewController, loader)
    }
    
    private func makeMovieItem(id: Int, title: String = "a movie title", overView: String = "a overview") -> Movie {
        Movie(id: id, title: "a movie title", overview: "a overview", poster_path: "http://image.tmdb.org/t/p/", backdrop_path: nil, release_date: nil, revenue: nil)
        
    }
    
    private class FeedServiceSpy: FeedLoader, ImageDataLoader {
        
        private var messages: [PassthroughSubject<[Movie], Error>] = []

        func fetchPopularMovies(page: Int) -> AnyPublisher<[Movie], Error> {
            let publisher = PassthroughSubject<[Movie], Error>()
            messages.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataLoaderTask {
            return Task()
        }
        
        func complete(with items: [Movie], at index: Int = 0) {
            messages[index].send(items)
            messages[index].send(completion: .finished)
        }
        
        func completeWithError(_ error: Error, at index: Int = 0) {
            messages[index].send(completion: .failure(error))
        }
        
        func getMovieDetail(_ id: Int, completion: @escaping (Result<Movie, Error>) -> Void) { }
    }
    
    struct Task: ImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
}

class DraggingScrollView: UIScrollView {
    override var isDragging: Bool {
        return true
    }
}

extension XCTestCase {
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dellocated. Potential memory leak", file: file, line: line)
        }
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0))
            }
        }

    }
}
