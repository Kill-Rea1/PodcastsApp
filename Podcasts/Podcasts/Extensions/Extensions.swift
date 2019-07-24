//
//  Extensions.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 23/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import Foundation
import FeedKit
import AVKit

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

extension CMTime {
    func toTimeString() -> String {
        if CMTimeGetSeconds(self).isNaN {
            return "--:--:--"
        }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let hours = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

extension UIApplication {
    static func mainTabBarController() -> MainTabController {
        return shared.keyWindow?.rootViewController as! MainTabController
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
    
    func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let leading = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: leading).isActive = true
        }
        
        if let trailing = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: trailing).isActive = true
        }
        
        if let top = superview?.topAnchor {
            topAnchor.constraint(equalTo: top).isActive = true
        }
        
        if let bottom = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: bottom).isActive = true
        }
    }
}

struct AnchoredConstraints {
    var leading, trailing, top, bottom, width, height: NSLayoutConstraint?
}
