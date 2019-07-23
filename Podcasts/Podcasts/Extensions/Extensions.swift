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
extension UIView {
    @discardableResult
    func addConsctraints(_ leading: NSLayoutXAxisAnchor?, _ trailing: NSLayoutXAxisAnchor?, _ top: NSLayoutYAxisAnchor?, _ bottom: NSLayoutYAxisAnchor?, _ padding: UIEdgeInsets = .zero, _ size: CGSize = .zero) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }
        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }
        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        
        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
        [anchoredConstraints.leading, anchoredConstraints.trailing, anchoredConstraints.top, anchoredConstraints.bottom, anchoredConstraints.width, anchoredConstraints.height].forEach({$0?.isActive = true})
        return anchoredConstraints
    }
}

struct AnchoredConstraints {
    var leading, trailing, top, bottom, width, height: NSLayoutConstraint?
}