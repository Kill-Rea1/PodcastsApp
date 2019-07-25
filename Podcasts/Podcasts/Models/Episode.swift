//
//  Episode.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 23/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import Foundation
import FeedKit

struct Episode: Codable {
    let title: String
    let author: String
    let pubDate: Date
    let description: String
    let episodeUrl: String
    var imageUrl: String?
    var fileUrl: String?
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.episodeUrl = feedItem.enclosure?.attributes?.url ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
    
    static let downloadedEpisodeKey = "downloadedEpisodeKey"
    
    static func downloadEpisode(episode: Episode) {
        do {
            var downloadedEpisodes = Episode.fetchDownloadedEpisodes()
            downloadedEpisodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(downloadedEpisodes)
            UserDefaults.standard.set(data, forKey: Episode.downloadedEpisodeKey)
        } catch let downloadError {
            print("Failed to download episode:", downloadError)
        }
    }
    
    static func fetchDownloadedEpisodes() -> [Episode] {
        guard let data = UserDefaults.standard.data(forKey: Episode.downloadedEpisodeKey) else { return [] }
        do {
            return try JSONDecoder().decode([Episode].self, from: data)
        } catch let decodeError {
            print("Failed to decode episodes:", decodeError)
            return []
        }
    }
    
    static func deleteEpisode(at index: Int) {
        do {
            var downloadedEpisodes = Episode.fetchDownloadedEpisodes()
            downloadedEpisodes.remove(at: index)
            let data = try JSONEncoder().encode(downloadedEpisodes)
            UserDefaults.standard.set(data, forKey: Episode.downloadedEpisodeKey)
        } catch let deleteError {
            print("Failed to delete episode:", deleteError)
        }
    }
}
