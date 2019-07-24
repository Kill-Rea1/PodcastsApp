//
//  MainTabController.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 20/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {
    
    fileprivate var maximizedTopConstraint: NSLayoutConstraint!
    fileprivate var minimizedTopConstraint: NSLayoutConstraint!
    fileprivate var bottomConstraint: NSLayoutConstraint!
    fileprivate let playerDetailsView = PlayerDetailsView.initFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .purple
        setupViewControllers()
        setupPlayerDetailsView()
    }
    
    fileprivate func performAnimations(maximized: Bool) {
        if maximized {
            minimizedTopConstraint.isActive = false
            maximizedTopConstraint.constant = 0
            bottomConstraint.constant = 0
            maximizedTopConstraint.isActive = true
        } else {
            maximizedTopConstraint.isActive = false
            bottomConstraint.constant = view.frame.height - tabBar.frame.height - 64
            minimizedTopConstraint.isActive = true
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = maximized ? CGAffineTransform(translationX: 0, y: 100) : .identity
            self.playerDetailsView.maximizedPlayerView.alpha = maximized ? 1 : 0
            self.playerDetailsView.miniPlayerView.alpha = maximized ? 0 : 1
        })
    }
    
    fileprivate func minimizePlayerDetails() {
        performAnimations(maximized: false)
    }
    
    public func maximizePlayerDetails(episode: Episode?) {
        if episode != nil {
            playerDetailsView.episode = episode
        }
        performAnimations(maximized: true)
    }
    
    fileprivate func setupPlayerDetailsView() {
        playerDetailsView.delegate = self
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        bottomConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomConstraint.isActive = true
        maximizedTopConstraint.isActive = true
        minimizedTopConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
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
    
    func maximize() {
        maximizePlayerDetails(episode: nil)
    }
}
