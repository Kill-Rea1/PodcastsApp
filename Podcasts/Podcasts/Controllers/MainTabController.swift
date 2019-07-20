//
//  MainTabController.swift
//  Podcasts
//
//  Created by Кирилл Иванов on 20/07/2019.
//  Copyright © 2019 Kirill Ivanoff. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .purple
        viewControllers = [
            createViweController(viewController: UIViewController(), title: "Search", imageName: "search"),
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
