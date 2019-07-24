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
    
    fileprivate let cellId = "episodesCell"
    fileprivate let favoritedPodcatKey = "favoritedPodcatKey"
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
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavourite)),
            UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts))
        ]
    }
    
    @objc fileprivate func handleFetchSavedPodcasts() {
        guard let data = UserDefaults.standard.data(forKey: favoritedPodcatKey) else { return }
        do {
            let podcast = try NSKeyedUnarchiver.unarchivedObject(ofClass: Podcast.self, from: data)
            print(podcast?.trackName ?? "")
        } catch let unarchiveError {
            print("Failed to unarchive data:", unarchiveError)
        }
    }
    
    @objc fileprivate func handleSaveFavourite() {
        guard let podcast = podcast else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: podcast, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: favoritedPodcatKey)
        } catch let archiveError {
            print("Failed to archive data:", archiveError)
        }
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
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activitiIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activitiIndicatorView.color = .darkGray
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
