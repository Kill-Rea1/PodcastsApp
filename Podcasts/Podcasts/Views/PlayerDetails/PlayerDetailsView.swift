//
//  PlayerDetailsView.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 23/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit

class PlayerDetailsView: UIView {
    fileprivate let startTransform = CGAffineTransform(translationX: 0, y: 1000)
    fileprivate let threshold: CGFloat = 200
    fileprivate let velocityThreshold: CGFloat = 500
    public var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            episodeImageView.layer.cornerRadius = 8
            contentView.layer.cornerRadius = 16
            guard let url = URL(string: episode.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        }
    }
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
    
    @IBAction func handleDismiss(_ sender: Any) {
        performAnimations(transform: startTransform, alpha: 0)
    }
    
    public func performAnimations(firstAnimation: Bool = false, transform: CGAffineTransform, alpha: CGFloat) {
        if firstAnimation {
            contentView.transform = startTransform
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.contentView.transform = transform
            self.backgroundColor = UIColor(white: 0, alpha: alpha)
        }) { (_) in
            if transform != .identity {
                self.removeFromSuperview()
            }
        }
    }
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        if gesture.state == .changed {
            let y = max(0, translation.y)
            let transform = CGAffineTransform(translationX: 0, y: y)
            let alpha: CGFloat = 0.7 - y / 1000
            backgroundColor = UIColor(white: 0, alpha: alpha)
            contentView.transform = transform
        } else if gesture.state == .ended {
            if translation.y > threshold || velocity.y > velocityThreshold {
                performAnimations(transform: startTransform, alpha: 0)
            } else {
                performAnimations(transform: .identity, alpha: 0.7)
            }
        }
    }
}
