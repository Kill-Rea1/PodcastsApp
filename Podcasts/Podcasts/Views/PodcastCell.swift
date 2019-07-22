//
//  PodcastCell.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 22/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            episodCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
            podcastImageView.sd_setImage(with: url)
            
            // Raw loading data image
//            URLSession.shared.dataTask(with: url) { (data, _, error) in
//                if let error = error {
//                    print("Failed to load image:", error)
//                    return
//                }
//                guard let data = data else { return }
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//            }.resume()
        }
    }
    
}
