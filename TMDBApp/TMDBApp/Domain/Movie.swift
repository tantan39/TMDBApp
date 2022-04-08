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
}
