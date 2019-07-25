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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadedEpisodes = Episode.fetchDownloadedEpisodes()
        tableView.reloadData()
        UIApplication.mainTabBarController().viewControllers?[2].tabBarItem.badgeValue = nil
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: episodeCellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: episodeCellId, for: indexPath) as! EpisodeCell
        cell.episode = downloadedEpisodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            self.downloadedEpisodes.remove(at: indexPath.item)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            Episode.deleteEpisode(at: indexPath.row)
        }
        return [deleteAction]
    }
}
