//
//  UpcomingViewController.swift
//  Movies
//
//  Created by Prashant Singh on 25/2/21.
//  Copyright © 2021 Prashant Singh. All rights reserved.
//

import UIKit

class UpcomingViewController: UITableViewController {
    
    
    let activityView = UIActivityIndicatorView(style: .large)
    let appThemeColor:UIColor = .systemYellow

    override func viewDidLoad() {
        super.viewDidLoad()
                        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        FetchMovies.shared.fetchMoviesDelegate = self
        FetchMovies.shared.fetchUpcomingMovies()
                
        activityView.hidesWhenStopped = true
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        self.tabBarController?.view.isUserInteractionEnabled = false
        
        
        self.navigationController?.navigationBar.backgroundColor = appThemeColor
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = appThemeColor
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        self.tabBarController?.tabBar.barTintColor = appThemeColor
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let upcomingMovieCell = tableView.dequeueReusableCell(withIdentifier: "upcomingIdentifier", for: indexPath)
            let upcomingMovie = FetchMovies.shared.upcomingMovies[indexPath.row]
            
            upcomingMovieCell.textLabel?.text = upcomingMovie.title
            upcomingMovieCell.detailTextLabel?.text = String(upcomingMovie.rating) + " ★"
            upcomingMovieCell.imageView?.image = upcomingMovie.smallImage
            
            return upcomingMovieCell

        }
            
        override func numberOfSections(in tableView: UITableView) -> Int {
            1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            FetchMovies.shared.upcomingMovies.count
        }

        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        }

    }

    extension UpcomingViewController: FetchMoviesDelegate{
        func didFetchMovies() {
            self.tableView.reloadData()
            self.tabBarController?.view.isUserInteractionEnabled = true
            activityView.stopAnimating()
        }


}

