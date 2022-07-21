//
//  MovieCellViewModel.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/20/22.
//

import Foundation

struct MovieCellViewModel<Image> {
    let movieID: Int?
    let posterURL: URL?
    let title: String?
    let overview: String?
    let image: Image?
    let isLoading: Bool
}
