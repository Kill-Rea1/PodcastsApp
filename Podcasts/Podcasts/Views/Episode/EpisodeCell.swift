//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 23/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit

protocol EpisodeCellDelegate {
    func handleDownload(title: String)
}

class EpisodeCell: UITableViewCell {
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var downloadProgressLabel: UILabel! 
    @IBOutlet weak var downloadButton: UIButton! {
        didSet {
            downloadButton.addTarget(self, action: #selector(handleDownloadEpisode), for: .touchUpInside)
        }
    }
    
    public var delegate: EpisodeCellDelegate?
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
    
    @objc fileprivate func handleDownloadEpisode() {
        delegate?.handleDownload(title: titleLabel.text ?? "")
        downloadButton.isHidden = true
    }
    
    fileprivate func getDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
}
