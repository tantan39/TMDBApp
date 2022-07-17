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
        let refreshViewController = FeedRefreshViewController(apiService: service)

        let vc = ViewController(apiService: service, imageLoader: service, refreshViewController: refreshViewController) { [weak self] id in
            guard let self = self else { return }
            self.navController?.pushViewController(MovieDetailVC(service: service, imageLoader: service, movieID: id), animated: true)
        }
        
        refreshViewController.onRefresh = { [weak vc] movies in
            let controllers = movies.map { MovieCellController(movie: $0, imageLoader: service) }
            vc?.set(controllers)
        }
        
        return vc
    }

}
