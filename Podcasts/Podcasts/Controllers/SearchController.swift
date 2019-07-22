//
//  SearchController.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 22/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit
import Alamofire

class SearchController: UITableViewController {
    
    fileprivate let cellId = "podcastCell"
    
    fileprivate var podcasts = [Podcast]()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
    }
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter search term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 250
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
        return cell
    }
}

extension SearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts, error) in
            if error != nil {
                return
            }
            guard let podcasts = podcasts  else { return }
            self.podcasts = podcasts
            self.tableView.reloadData()
        }
    }
}
