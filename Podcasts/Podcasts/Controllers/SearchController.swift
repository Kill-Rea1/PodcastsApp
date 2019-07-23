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
    fileprivate var timer: Timer?
    
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
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    fileprivate func footerView() -> UIView {
        let footerView = UIView()
        let activitiIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activitiIndicatorView.color = .darkGray
        activitiIndicatorView.startAnimating()
        
        let label = UILabel()
        label.text = "Currently searching"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        let stackView = UIStackView(arrangedSubviews: [UIView(), activitiIndicatorView, label])
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.axis = .vertical
        
        footerView.addSubview(stackView)
        stackView.addConsctraints(footerView.leadingAnchor, footerView.trailingAnchor, footerView.topAnchor, footerView.bottomAnchor)
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == false ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter search term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == true ? 250 : 0
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        let podcast = podcasts[indexPath.row]
        episodesController.podcast = podcast
        navigationController?.pushViewController(episodesController, animated: true)
    }
}

extension SearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        podcasts = []
        tableView.reloadData()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            APIService.shared.fetchPodcasts(searchText: searchText) { [unowned self] (podcasts, error) in
                if error != nil {
                    return
                }
                guard let podcasts = podcasts  else { return }
                self.podcasts = podcasts
                self.tableView.reloadData()
            }
        })
    }
}
