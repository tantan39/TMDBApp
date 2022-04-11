//
//  URLSessionHTTPClient.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/11/22.
//

import Foundation

class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
        
    func get(url: URL, completion: @escaping (Result<(data: Data, response: HTTPURLResponse), Swift.Error>) -> Void) {
        session.dataTask(with: url) { data, response, error in
            completion(Result {
              if let error = error {
                throw error
              } else if let data = data, let response = response as? HTTPURLResponse {
                return (data, response)
              } else {
                  throw Error.connectionError
              }
            })
        }
        .resume()
    }
}
