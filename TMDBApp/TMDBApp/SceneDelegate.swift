//
//  SceneDelegate.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import UIKit

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
        let service = FeedAPIService(httpClient: URLSessionHTTPClient(session: .shared))
        let refreshViewModel = FeedRefreshViewModel(apiService: service)
        let refreshViewController = FeedRefreshViewController(viewModel: refreshViewModel)
        let loadMoreController = LoadMoreCellController(apiService: service)

        let vc = ViewController(refreshViewController: refreshViewController, loadMoreController: loadMoreController) { [weak self] id in
            guard let self = self else { return }
            self.navController?.pushViewController(MovieDetailVC(service: service, imageLoader: service, movieID: id), animated: true)
        }
        
        refreshViewModel.onFeedLoad = { [weak vc] movies in
            let controllers = movies.map { MovieCellController(movie: $0, imageLoader: service) }
            vc?.set(controllers)
        }
        
        loadMoreController.onPaging = { [weak vc] movies in
            let controllers = movies.map { MovieCellController(movie: $0, imageLoader: service) }
            vc?.append(controllers)
        }
        
        return vc
    }

}
