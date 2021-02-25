//
//  TopRatedViewController.swift
//  Movies
//
//  Created by Prashant Singh on 25/2/21.
//  Copyright © 2021 Prashant Singh. All rights reserved.
//

import UIKit

class TopRatedViewController: UITableViewController {

    let activityView = UIActivityIndicatorView(style: .large)
    let appThemeColor:UIColor = .systemYellow
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        FetchMovies.shared.fetchMoviesDelegate = self
        FetchMovies.shared.fetchTopRatedMovies()
        
        
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
        
        let topRatedMovieCell = tableView.dequeueReusableCell(withIdentifier: "topRatedIdentifier", for: indexPath)
        let topRatedMovie = FetchMovies.shared.topRatedMovies[indexPath.row]
        
        topRatedMovieCell.textLabel?.text = topRatedMovie.title
        topRatedMovieCell.detailTextLabel?.text = String(topRatedMovie.rating) + " ★"
        //topRatedMovieCell.imageView?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        topRatedMovieCell.imageView?.image = topRatedMovie.smallImage
        
        return topRatedMovieCell

    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FetchMovies.shared.topRatedMovies.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension TopRatedViewController: FetchMoviesDelegate{
    func didFetchMovies() {
        self.tableView.reloadData()
        self.tabBarController?.view.isUserInteractionEnabled = true
        activityView.stopAnimating()
    }
    
    
}

