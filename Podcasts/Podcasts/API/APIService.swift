//
//  APIService.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 22/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    static let shared = APIService()
    public typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
    fileprivate let baseiTunesUrl = "https://itunes.apple.com/search"
    
    public func downloadEpisode(episode: Episode) {
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        Alamofire.download(episode.episodeUrl, to: downloadRequest).downloadProgress { (progress) in
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
        }.response { (response) in
            let episodeDownloadComplete = EpisodeDownloadCompleteTuple(response.destinationURL?.absoluteString ?? "", episode.title)
            NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete)
            var downloadedEpisodes = Episode.fetchDownloadedEpisodes()
            guard let index = downloadedEpisodes.firstIndex(where: {$0.title == episode.title && $0.author == episode.author}) else { return }
            downloadedEpisodes[index].fileUrl = response.destinationURL?.absoluteString ?? ""
            do {
                let data = try JSONEncoder().encode(downloadedEpisodes)
                UserDefaults.standard.set(data, forKey: Episode.downloadedEpisodeKey)
            } catch let downloadError {
                print("Failed to save file url:", downloadError)
            }
        }
    }
    
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
    
    public func fetchEpisodes(feedUrl: String, completion: @escaping ([Episode]?, Error?) -> ()) {
        let secureFeedUrl = feedUrl.toSecureHTTPS()
        guard let url = URL(string: secureFeedUrl) else { return }
        DispatchQueue.global(qos: .background).async {
            let feedParser = FeedParser(URL: url)
            
            feedParser.parseAsync { (result) in
                if let error = result.error {
                    print("Failed to parse feed:", error)
                    completion(nil, error)
                    return
                }
                
                guard let feed = result.rssFeed else { return }
                let episodes = feed.toEpisodes()
                completion(episodes, nil)
            }
        }
    }
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
}
