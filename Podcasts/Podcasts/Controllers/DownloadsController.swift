//
//  DownloadsController.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 25/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
    
    fileprivate let episodeCellId = "episodeCell"
    fileprivate var downloadedEpisodes = Episode.fetchDownloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadedEpisodes = Episode.fetchDownloadedEpisodes()
        tableView.reloadData()
        UIApplication.mainTabBarController().viewControllers?[2].tabBarItem.badgeValue = nil
    }
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    @objc fileprivate func handleDownloadComplete(notification: Notification) {
        guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else { return }
        guard let index = downloadedEpisodes.firstIndex(where: {$0.title == episodeDownloadComplete.episodeTitle}) else { return }
        downloadedEpisodes[index].fileUrl = episodeDownloadComplete.fileUrl
    }
    
    @objc fileprivate func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let title = userInfo["title"] as? String else { return }
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let index = downloadedEpisodes.firstIndex(where: {$0.title == title}) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        cell.downloadProgressLabel.isHidden = false
        cell.downloadProgressLabel.text = "\(Int(progress * 100))%"
        cell.downloadProgressLabel.isHidden = progress == 1
        cell.episodeImageView.layer.opacity = progress == 1 ? 1 : 0.5
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: episodeCellId)
    }
    
    // MARK:- UITableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = downloadedEpisodes[indexPath.row]
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController().maximizePlayerDetails(episode: episode, playlistEpisodes: downloadedEpisodes)
        } else {
            let alertController = UIAlertController(title: "File URL Not Found", message: "Cannot find local file, play using stream URL", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                UIApplication.mainTabBarController().maximizePlayerDetails(episode: episode, playlistEpisodes: self.downloadedEpisodes)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: episodeCellId, for: indexPath) as! EpisodeCell
        cell.episode = downloadedEpisodes[indexPath.row]
        cell.downloadButton.isHidden = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            guard let episodeUrl = URL(string: self.downloadedEpisodes[indexPath.row].fileUrl ?? "") else { return }
            guard let trueLocation = FileManager.getPathToFile(fileName: episodeUrl.lastPathComponent) else { return }
            self.downloadedEpisodes.remove(at: indexPath.item)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            Episode.deleteEpisode(at: indexPath.row)
            do {
                try FileManager.default.removeItem(at: trueLocation)
            } catch let deleteError {
                print("Failed to delete from device:", deleteError)
                return
            }
        }
        return [deleteAction]
    }
}
