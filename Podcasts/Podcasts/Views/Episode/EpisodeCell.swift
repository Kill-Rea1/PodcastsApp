//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 23/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    public var episode: Episode! {
        didSet {
            pubDateLabel.text = getDate(date: episode.pubDate)
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            episodeImageView.layer.cornerRadius = 8
            guard let imageUrl = episode.imageUrl?.toSecureHTTPS() else { return }
            guard let url = URL(string: imageUrl) else { return }
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    fileprivate func getDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
}
