//
//  PlayerDetailsView.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 23/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit
import AVKit

class PlayerDetailsView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        observerStartsPlayer()
        observerPlayerCurrentTime()
    }
    
    fileprivate let startTransform = CGAffineTransform(translationX: 0, y: 1000)
    fileprivate let threshold: CGFloat = 200
    fileprivate let scale: CGFloat = 0.7
    fileprivate let velocityThreshold: CGFloat = 500
    public var episode: Episode! {
        didSet {
            setupViews()
            playEpisode()
        }
    }
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 8
            episodeImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    fileprivate let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    fileprivate func observerPlayerCurrentTime() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = self?.getTimeString(time: time)
            let duration = self?.player.currentItem?.duration
            self?.durationTimeLabel.text = self?.getTimeString(time: duration!)
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        currentTimeSlider.value = Float(percentage)
    }
    
    fileprivate func getTimeString(time: CMTime) -> String {
        var totalSeconds = 0
        let timeFloat = CMTimeGetSeconds(time)
        if !(timeFloat.isNaN || timeFloat.isInfinite) {
            totalSeconds = Int(timeFloat)
        }
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        if totalSeconds / 3600 > 0 {
            let hours = totalSeconds / 3600
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    fileprivate func observerStartsPlayer() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.animateEpisodeImageView()
        }
    }
    
    @objc fileprivate func handlePlayPause(sender: UIButton) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
        animateEpisodeImageView()
    }
    
    fileprivate func animateEpisodeImageView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            if self.episodeImageView.transform != .identity {
                self.episodeImageView.transform = .identity
            } else {
                self.episodeImageView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
            }
        })
    }
    
    fileprivate func playEpisode() {
        guard let url = URL(string: episode.episodeUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
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
//                self.player.removeTimeObserver(self)
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
    
    fileprivate func setupViews() {
        titleLabel.text = episode.title
        authorLabel.text = episode.author
        episodeImageView.layer.cornerRadius = 8
        contentView.layer.cornerRadius = 16
        guard let url = URL(string: episode.imageUrl ?? "") else { return }
        episodeImageView.sd_setImage(with: url)
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
    }
    
    
    
    @IBAction func handleDismiss(_ sender: Any) {
        performAnimations(transform: startTransform, alpha: 0)
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        
        player.seek(to: seekTime)
    }
    
    @IBAction func handleFastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleRewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
}
