//
//  MovieDetailVC.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/8/22.
//

import Foundation
import UIKit

class MovieDetailVC: UIViewController {
    var movieID: Int?
    let service = FeedAPIService()
    
    convenience init(movieID: Int) {
        self.init()
        self.movieID = movieID
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        getDetail()
    }
    
    private func getDetail() {
        guard let id = movieID else {
            return
        }
        service.getMovieDetail(id) { result in
            switch result {
            case let .success(movie):
                print(movie.title)
            default:
                break
            }
        }
    }
}
