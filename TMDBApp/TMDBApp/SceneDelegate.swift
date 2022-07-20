//
//  SceneDelegate.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var navController: UINavigationController?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        self.navController = UINavigationController(rootViewController: makeViewController())
        window?.rootViewController = self.navController
        window?.makeKeyAndVisible()
    }
    
    func makeViewController() -> ViewController {
        let service = FeedAPIService(httpClient: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)))
        let presenter = FeedPresenter()
        let adapter = FeedLoaderPresentationAdapter(presenter: presenter, loader: service)
        let refreshViewController = FeedRefreshViewController(delegate: adapter)
        let loadMoreViewModel = LoadMoreCellViewModel(apiService: service)
        let loadMoreController = LoadMoreCellController(viewModel: loadMoreViewModel)

        let vc = ViewController(refreshViewController: refreshViewController, loadMoreController: loadMoreController) { [weak self] id in
            guard let self = self else { return }
            self.navController?.pushViewController(MovieDetailVC(service: service, imageLoader: service, movieID: id), animated: true)
        }
        
        presenter.loadingView = WeakRefVirtualProxy(object: refreshViewController)
        presenter.feedView = FeedViewAdapter(controller: vc, loader: service)
        
        loadMoreViewModel.onPaging = { [weak vc] movies in
            let controllers = movies.map { MovieCellController(viewModel: MovieCellViewModel(movie: $0, imageLoader: service, imageTransformer: UIImage.init)) }
            vc?.append(controllers)
        }
        
        return vc
    }

}

class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let presenter: FeedPresenter
    private let loader: FeedLoader
    private var cancellables = Set<AnyCancellable>()
    
    internal init(presenter: FeedPresenter, loader: FeedLoader) {
        self.presenter = presenter
        self.loader = loader
    }
    
    func didRequestRefresh() {
        self.presenter.didStartLoadingFeed()
        loader.fetchPopularMovies(page: 1)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let err):
                    self?.presenter.didFinishLoadingFeed(err)
                default:
                    break
                }
            }, receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.presenter.didFinishLoadingFeed(movies)
            })
            .store(in: &cancellables)
    }
}

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}
