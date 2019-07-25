//
//  Podcast.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 22/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import Foundation

class Podcast: NSObject, Decodable, NSCoding, NSSecureCoding {
    
    required init?(coder aDecoder: NSCoder) {
        self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: "artworkUrlKey") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(trackName ?? "", forKey: "trackNameKey")
        aCoder.encode(artistName ?? "", forKey: "artistNameKey")
        aCoder.encode(artworkUrl600 ?? "", forKey: "artworkUrlKey")
    }
    
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
    
    static let favoritedPodcastKey = "favoritedPodcatKey"
    static var supportsSecureCoding: Bool {
        return true
    }
    
    static func savePodcasts(podcasts: [Podcast]) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: podcasts as Array, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: Podcast.favoritedPodcastKey)
        } catch let archiveError {
            print("Failed to archive data:", archiveError)
        }
    }
    
    static func fetchSavedPodcasts() -> [Podcast] {
        guard let data = UserDefaults.standard.data(forKey: Podcast.favoritedPodcastKey) else { return []}
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Podcast.self], from: data) as! [Podcast]
        } catch let unarchiveError {
            print("Failed to unarchive data:", unarchiveError)
            return []
        }
    }
}
