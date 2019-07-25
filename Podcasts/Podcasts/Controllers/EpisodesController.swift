//
//  EpisodesController.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 23/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    fileprivate let heartButton = UIBarButtonItem(image: #imageLiteral(resourceName: "35 heart"), style: .plain, target: nil, action: nil)
    fileprivate let cellId = "episodesCell"
    fileprivate var episodes = [Episode]()
    public var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        navigationBarItems()
    }
    
    fileprivate func navigationBarItems() {
        let savedPoscasts = Podcast.fetchSavedPodcasts()
        let hasFavorited = savedPoscasts.firstIndex(where: {$0.trackName == podcast?.trackName && $0.artistName == podcast?.artistName}) != nil
        if hasFavorited {
            navigationItem.rightBarButtonItem = heartButton
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavourite))
        }
    }
    
    @objc fileprivate func handleSaveFavourite() {
        guard let podcast = podcast else { return }
        var listPodcasts = Podcast.fetchSavedPodcasts()
        listPodcasts.append(podcast)
        Podcast.savePodcasts(podcasts: listPodcasts)
        navigationItem.rightBarButtonItem = heartButton
        showBadgeHighlited()
    }
    
    fileprivate func showBadgeHighlited() {
        UIApplication.mainTabBarController().viewControllers?[0].tabBarItem.badgeValue = "New"
    }

    fileprivate func fetchEpisodes() {
        guard let feedUrl = podcast?.feedUrl else { return }
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes, error) in
            if error != nil {
                return
            }
            
            guard let episodes = episodes else { return }
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    // MARK:- UITableView
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            let episode = self.episodes[indexPath.row]
            let episodes = Episode.fetchDownloadedEpisodes()
            let isDownloaded = episodes.firstIndex(where: {$0.title == episode.title && $0.author == episode.author}) != nil
            if isDownloaded {
                return
            } else {
                Episode.downloadEpisode(episode: episode)
            }
            UIApplication.mainTabBarController().viewControllers?[2].tabBarItem.badgeValue = "New"
            APIService.shared.downloadEpisode(episode: episode)
        }
        return [downloadAction]
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activitiIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activitiIndicatorView.color = #colorLiteral(red: 0.5523580313, green: 0.2407458723, blue: 0.6643408537, alpha: 1)
        activitiIndicatorView.startAnimating()
        return activitiIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        let mainTabController = UIApplication.mainTabBarController()
        mainTabController.maximizePlayerDetails(episode: episode, playlistEpisodes: episodes)
    }
}
