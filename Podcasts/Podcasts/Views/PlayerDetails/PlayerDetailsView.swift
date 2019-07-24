//
//  PlayerDetailsView.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 23/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit
import AVKit

protocol PlayerDetailsDelegate {
    func dismiss()
    func maximaze()
}

class PlayerDetailsView: UIView {
    
    // MARK:- Properies
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    var delegate: PlayerDetailsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        observerStartsPlayer()
        observerPlayerCurrentTime()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximaze)))
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
    
    // MARK:- IBOutlets
    @IBOutlet weak var miniImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var maximizedPlayerView: UIStackView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
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
    
    // MARK:- Fileprivate Methods
    
    fileprivate let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    fileprivate func observerPlayerCurrentTime() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toTimeString()
            let duration = self?.player.currentItem?.duration
            self?.durationTimeLabel.text = duration?.toTimeString()
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        currentTimeSlider.value = Float(percentage)
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
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
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
    
    fileprivate func setupViews() {
        titleLabel.text = episode.title
        authorLabel.text = episode.author
        episodeImageView.layer.cornerRadius = 8
        guard let url = URL(string: episode.imageUrl ?? "") else { return }
        episodeImageView.sd_setImage(with: url)
        miniImageView.layer.cornerRadius = 8
        miniImageView.sd_setImage(with: url)
        miniTitleLabel.text = episode.title
    }
    
    @objc fileprivate func handleTapMaximaze() {
        delegate?.maximaze()
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    // MARK:- IBActions
    @IBAction func handleMiniPlayPause(_ sender: Any) {
    }
    @IBAction func handleMiniForward(_ sender: Any) {
        handleFastForward(sender)
    }
    
    @IBAction func handleDismiss(_ sender: Any) {
        delegate?.dismiss()
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
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
}
