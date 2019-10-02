//
//  FavouritesCell.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 25/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit

class FavouriteCell: UICollectionViewCell {
    
    public var podcast: Podcast! {
        didSet {
            authorLabel.text = podcast.artistName ?? ""
            podcatNameLabel.text = podcast.trackName ?? ""
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
            podcastImageView.sd_setImage(with: url)
        }
    }
    
    fileprivate lazy var podcastImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "appicon"))
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.heightAnchor.constraint(equalToConstant: frame.width).isActive = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    fileprivate let podcatNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.text = "PODCAST NAME"
        return label
    }()
    
    fileprivate let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "AUTHOR NAME"
        label.textColor = .lightGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupView()
    }
    
    fileprivate func setupView() {
        let overralStackView = UIStackView(arrangedSubviews: [
            podcastImageView, podcatNameLabel, authorLabel
            ])
        overralStackView.axis = .vertical
        podcastImageView.heightAnchor.constraint(equalToConstant: frame.width).isActive = true
        addSubview(overralStackView)
        overralStackView.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        print("Bye Bye")
    }
}
