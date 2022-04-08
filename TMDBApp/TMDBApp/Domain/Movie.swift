//
//  Movie.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/8/22.
//

import Foundation

struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
    let backdrop_path: String?
    let release_date: String?
    let revenue: Int?
    
    var backDropURL: URL? {
        guard let path = backdrop_path else {
            return nil
        }
        return URL(string: "\(ROOT_IMAGE)original/\(path)")!
    }
}
