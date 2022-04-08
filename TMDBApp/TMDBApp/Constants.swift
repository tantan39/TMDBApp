//
//  Constants.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import Foundation

let API_Key = "d30196018ffea96c0d32f84262af7fe6"
let ROOT = "https://api.themoviedb.org/3/movie/popular"

struct Endpoint {
    static let popularMovies: (_ page: Int) -> String = { page in
        return "\(ROOT)/?api_key=\(API_Key)&page=\(page)"
    }
}
