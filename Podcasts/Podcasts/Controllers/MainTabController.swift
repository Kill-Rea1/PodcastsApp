//
//  MainTabController.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 20/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {
    
    var maximizedTopConstraint: NSLayoutConstraint!
    var minimizedTopConstraint: NSLayoutConstraint!
    let playerDetailsView = PlayerDetailsView.initFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .purple
        setupViewControllers()
        setupPlayerDetailsView()
    }
    
    fileprivate func minimizePlayerDetails() {
        maximizedTopConstraint.isActive = false
        minimizedTopConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
        })
    }
    
    func maximizePlayerDetails(episode: Episode?) {
        maximizedTopConstraint.isActive = true
        maximizedTopConstraint.constant = 0
        minimizedTopConstraint.isActive = false
        
        if episode != nil {
            playerDetailsView.episode = episode
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
        })
    }
    
    fileprivate func setupPlayerDetailsView() {
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopConstraint.isActive = true
        minimizedTopConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        
    }
    
    fileprivate func setupViewControllers() {
        viewControllers = [
            createViweController(viewController: SearchController(), title: "Search", imageName: "search"),
            createViweController(viewController: FavoritesController(), title: "Favorites", imageName: "favorites"),
            createViweController(viewController: UIViewController(), title: "Downloads", imageName: "downloads")
        ]
    }
    
    fileprivate func createViweController(viewController: UIViewController ,title: String, imageName: String) -> UIViewController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.prefersLargeTitles = true
        viewController.navigationItem.title = title
        viewController.view.backgroundColor = .white
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
}

extension MainTabController: PlayerDetailsDelegate {
    func dismiss() {
        minimizePlayerDetails()
    }
    
    func maximaze() {
        maximizePlayerDetails(episode: nil)
    }
}
