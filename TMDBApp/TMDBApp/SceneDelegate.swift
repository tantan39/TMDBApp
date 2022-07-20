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
        let adapter = FeedLoaderPresentationAdapter(loader: service)
        let refreshViewController = FeedRefreshViewController(delegate: adapter)
        let loadMoreViewModel = LoadMoreCellViewModel(apiService: service)
        let loadMoreController = LoadMoreCellController(viewModel: loadMoreViewModel)

        let vc = ViewController(refreshViewController: refreshViewController, loadMoreController: loadMoreController) { [weak self] id in
            guard let self = self else { return }
            self.navController?.pushViewController(MovieDetailVC(service: service, imageLoader: service, movieID: id), animated: true)
        }
        
        adapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: vc, loader: service),
            loadingView: WeakRefVirtualProxy(refreshViewController))
        
        loadMoreViewModel.onPaging = { [weak vc] movies in
            let controllers = movies.map { model -> MovieCellController in
                let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<MovieCellController>, UIImage>(model: model, imageLoader: service)
                let view = MovieCellController(delegate: adapter, movieID: model.id)
                adapter.presenter = MovieCellPresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
                return view
            }
            vc?.append(controllers)
        }
        
        return vc
    }

}

class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    var presenter: FeedPresenter?
    private let loader: FeedLoader
    private var cancellables = Set<AnyCancellable>()
    
    internal init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestRefresh() {
        self.presenter?.didStartLoadingFeed()
        loader.fetchPopularMovies(page: 1)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let err):
                    self?.presenter?.didFinishLoadingFeed(with: err)
                default:
                    break
                }
            }, receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.presenter?.didFinishLoadingFeed(with: movies)
            })
            .store(in: &cancellables)
    }
}

class FeedImageDataLoaderPresentationAdapter<View: MovieImageView, Image>: MovieCellControllerDelegate where View.Image == Image {
    var presenter: MovieCellPresenter<View, Image>?
    
    private let model: Movie
    private let imageLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    private var cancellables = Set<AnyCancellable>()
    
    var posterURL: URL? {
        let url = URL(string: "\(ROOT_IMAGE)w500/\(self.model.poster_path)")
        return url
    }
    
    internal init(model: Movie, imageLoader: ImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        if let posterURL = posterURL {
            let model = self.model
            presenter?.didStartLoadingImage(for: model)
            self.task = self.imageLoader.loadImageData(from: posterURL) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.presenter?.didFinishLoadingImage(with: data, for: model)
                    case .failure(let error):
                        self.presenter?.didFinishLoadingImage(with: error, for: model)
                    }
                }
            }
        }
    }
    
    func didCancelImageRequest() {
        self.task?.cancel()
        self.task = nil
    }
}

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: MovieImageView where T: MovieImageView, T.Image == UIImage {
     func display(_ model: MovieCellViewModel<UIImage>) {
         object?.display(model)
     }
 }
