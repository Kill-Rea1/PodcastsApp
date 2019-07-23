//
//  Extensions.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 23/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import Foundation
import FeedKit

extension String {
    func toSecureHTTPS() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}

extension RSSFeed {
    func toEpisodes() -> [Episode] {
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        var _episodes = [Episode]()
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            episode.imageUrl = episode.imageUrl == nil ? imageUrl : episode.imageUrl
            _episodes.append(episode)
        })
        return _episodes
    }
}
