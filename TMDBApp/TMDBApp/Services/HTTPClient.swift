//
//  HTTPClient.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/11/22.
//

import Foundation

enum Error: Swift.Error {
    case invalidData
    case connectionError
}

protocol HTTPClient {
    func get(url: URL, completion: @escaping (Result<(data: Data, response: HTTPURLResponse), Swift.Error>) -> Void)
}
