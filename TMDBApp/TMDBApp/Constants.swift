//
//  Constants.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import Foundation

let API_Key = "d30196018ffea96c0d32f84262af7fe6"
let ROOT = "https://api.themoviedb.org"
let ROOT_IMAGE = "http://image.tmdb.org/t/p/"

struct Endpoint {
    static let popularMovies: (_ page: Int) -> String = { page in
        return "\(ROOT)/3/movie/popular/?api_key=\(API_Key)&page=\(page)"
    }
    
    static let details: (_ id: Int) -> String = { id in
        return "\(ROOT)/3/movie/\(id)?api_key=\(API_Key)"
    }
}
