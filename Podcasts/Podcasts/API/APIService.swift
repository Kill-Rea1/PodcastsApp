//
//  APIService.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 22/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import Foundation
import Alamofire

class APIService {
    static let shared = APIService()
    fileprivate let baseiTunesUrl = "https://itunes.apple.com/search"
    
    public func fetchPodcasts(searchText: String, completion: @escaping ([Podcast]?, Error?) -> ()) {
        let parameters = ["term": searchText, "media": "podcast"]
        Alamofire.request(baseiTunesUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let error = dataResponse.error {
                print("Failed to connect to yahoo:", error)
                completion(nil, error)
                return
            }
            guard let data = dataResponse.data else { return }
            do {
                let searchResults = try JSONDecoder().decode(SearchResults.self, from: data)
                completion(searchResults.results, nil)
            } catch let jsonError {
                print("Failed to decode:", jsonError)
                completion(nil, jsonError)
            }
        }
    }
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
}
