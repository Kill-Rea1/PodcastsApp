//
//  PlayerDetailsView.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 23/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

protocol PlayerDetailsDelegate {
    func dismiss()
    func maximize()
}

class PlayerDetailsView: UIView {
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    // MARK:- Properies
    
    public var playlistEpisodes = [Episode]()
    public var delegate: PlayerDetailsDelegate?
    public var isMaximized = true
    fileprivate let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    fileprivate let threshold: CGFloat = 200
    fileprivate let scale: CGFloat = 0.7
    fileprivate let velocityThreshold: CGFloat = 500
    public var episode: Episode! {
        didSet {
            setupNowPlayinInfo()
            setupViews()
            setupAudioSession()
            playEpisode()
        }
    }
    
    // MARK:- Initilization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        observerStartsPlayer()
        observerPlayerCurrentTime()
        setupGestures()
        setupRemoteControl()
        setupInterruptionObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    // MARK:- IBOutlets
    @IBOutlet weak var miniImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    @IBOutlet weak var miniForwardButton: UIButton! {
        didSet {
            miniForwardButton.addTarget(self, action: #selector(handleFastForward(_:)), for: .touchUpInside)
            miniForwardButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
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
    
    fileprivate func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        if type == AVAudioSession.InterruptionType.began.rawValue {
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            animateEpisodeImageView(false)
        } else {
            guard let option = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if option == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                enablePlaying()
            }
        }
    }
    
    fileprivate func setupNowPlayinInfo() {
        var nowPlaingInfo = [String: Any]()
        nowPlaingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlaingInfo[MPMediaItemPropertyArtist] = episode.author
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaingInfo
    }
    
    fileprivate func enablePlaying() {
        player.play()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        animateEpisodeImageView(true)
    }
    
    fileprivate func enablePausing() {
        player.pause()
        playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        animateEpisodeImageView(false)
    }
    
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.enablePlaying()
            self.setupElapsedTime(playbackRate: 1)
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.enablePausing()
            self.setupElapsedTime(playbackRate: 0)
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
    }
    
    @objc fileprivate func handleNextTrack() -> MPRemoteCommandHandlerStatus {
        changeEpisodeTo(1)
        return .success
    }
    
    @objc fileprivate func handlePreviousTrack() -> MPRemoteCommandHandlerStatus {
        changeEpisodeTo(-1)
        return .success
    }
    
    fileprivate func changeEpisodeTo(_ newIndex: Int) {
        if playlistEpisodes.isEmpty {
            return
        }
        
        let currentEpisodeIndex = playlistEpisodes.firstIndex { (episode) -> Bool in
            return self.episode.title == episode.title && self.episode.author == episode.author
        }
        guard let index = currentEpisodeIndex else { return }
        var nextEpisode: Episode
        if index + newIndex > playlistEpisodes.count - 1 {
            nextEpisode = playlistEpisodes[0]
        } else if index + newIndex < 0 {
            nextEpisode = playlistEpisodes[playlistEpisodes.count - 1]
        } else {
            nextEpisode = playlistEpisodes[index + newIndex]
        }
        episode = nextEpisode
    }
    
    fileprivate func setupElapsedTime(playbackRate: Float) {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    fileprivate func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("Failed to activate sesstion:", error)
        }
    }
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximaze)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
    }
    
    fileprivate func observerPlayerCurrentTime() {
        let interval = CMTime(value: 1, timescale: 1)
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
            self?.animateEpisodeImageView(true)
            self?.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self?.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self?.setupLockscreenDuration()
        }
    }
    
    fileprivate func setupLockscreenDuration() {
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
    }
    
    @objc fileprivate func handlePlayPause() {
        var isPlaying: Bool
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            isPlaying = true
            setupElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            isPlaying = false
            setupElapsedTime(playbackRate: 0)
        }
        animateEpisodeImageView(isPlaying)
    }
    
    fileprivate func animateEpisodeImageView(_ isPlaying: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            if isPlaying {
                self.episodeImageView.transform = .identity
            } else {
                self.episodeImageView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
            }
        })
    }
    
    fileprivate func playEpisode() {
        var url: URL
        if episode.fileUrl != nil {
            guard let _url = URL(string: episode.fileUrl ?? "") else { return }
            let fileName = _url.lastPathComponent
            guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            trueLocation.appendPathComponent(fileName)
            try? FileManager.default.removeItem(at: trueLocation)
            url = trueLocation
        } else {
            guard let _url = URL(string: episode.episodeUrl) else { return }
            url = _url
        }
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
        miniImageView.sd_setImage(with: url) { (image, _, _, _) in
            guard let image = image else { return }
            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
                return image
            })
            nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
        miniTitleLabel.text = episode.title
    }
    
    @objc fileprivate func handleTapMaximaze() {
        delegate?.maximize()
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    // MARK:- IBActions
    
    @IBAction func handleDismiss(_ sender: Any) {
        delegate?.dismiss()
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
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

// MARK:- PanGesture Methods

extension PlayerDetailsView {
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handleChanged(gesture)
        } else if gesture.state == .ended {
            handleEnded(gesture)
        }
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        var translationY = gesture.translation(in: self.superview).y
        if !isMaximized {
            miniPlayerView.alpha = 1 + translationY / threshold
            maximizedPlayerView.alpha = 0 - translationY / threshold
            translationY = min(0, translationY)
        } else {
            translationY = max(0, translationY)
        }
        transform = CGAffineTransform(translationX: 0, y: translationY)
    }
    
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        var translation = gesture.translation(in: self.superview).y
        var velocity = gesture.velocity(in: self.superview).y
        if !isMaximized {
            translation = abs(translation)
            velocity = abs(translation)
        }
        let shoudlChange = translation > threshold || velocity > velocityThreshold
        performAnimations(shoudlChange)
    }
    
    fileprivate func performAnimations(_ shoudlChange: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            if shoudlChange {
                self.shouldChange()
            } else {
                self.shouldStay()
            }
        })
    }
    
    fileprivate func shouldChange() {
        if isMaximized {
            delegate?.dismiss()
        } else {
            delegate?.maximize()
        }
    }
    
    fileprivate func shouldStay() {
        transform = .identity
        if !isMaximized {
            miniPlayerView.alpha = 1
            maximizedPlayerView.alpha = 0
        }
    }
}
