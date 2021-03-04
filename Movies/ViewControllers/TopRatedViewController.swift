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
        
        //Setup the navigation bar and app theme color
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.backgroundColor = appThemeColor
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = appThemeColor
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        self.tabBarController?.tabBar.barTintColor = appThemeColor
                        
        //Setup the loading activity indicator
        activityView.hidesWhenStopped = true
        activityView.frame = CGRect(x: self.tabBarController!.view.frame.midX - 25, y: view.frame.midY - navigationController!.navigationBar.frame.maxY - 50, width: 50, height: 50)
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        //Disable the user interaction until the top rated movies have been downloaded.
        self.tabBarController?.view.isUserInteractionEnabled = false
        
        //Fetch the top rated movies
        FetchMovies.shared.fetchTopRatedMovies()
                                    
    }
    
    //Remove the fetch movies delegate
    override func viewWillDisappear(_ animated: Bool) {
        FetchMovies.shared.fetchMoviesDelegate = nil
    }
    
    //Set the fetch movies delegate
    override func viewDidAppear(_ animated: Bool) {
        FetchMovies.shared.fetchMoviesDelegate = self
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let topRatedMovieCell = tableView.dequeueReusableCell(withIdentifier: "topRatedIdentifier", for: indexPath)
        let topRatedMovie = FetchMovies.shared.topRatedMovies[indexPath.row]
        
        topRatedMovieCell.textLabel?.text = topRatedMovie.title
        topRatedMovieCell.detailTextLabel?.text = String(topRatedMovie.rating) + " ★"
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
                
        //Deselect the selectd row
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Show the activity indicator until the image has been downloaded.
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        //Disable the user interaction until the movie poster image has been downloaded.
        self.tabBarController?.view.isUserInteractionEnabled = false
        
        //Fetch the movie poster for the selected movie
        FetchMovies.shared.downloadPosterImage(forRow: indexPath.row, forTopRatedMovies: true)
                
    }
    
}

extension TopRatedViewController: FetchMoviesDelegate{
    
    
    func didFetchMovies() {
    
        //Reload the tableview when the toprated movies have been downloaded
        self.tableView.reloadData()
        
        //Enable the user interaction and stop the activity indicator
        self.tabBarController?.view.isUserInteractionEnabled = true
        activityView.stopAnimating()
    }
    
    func didDownloadPosterImage(forRow: Int) {
     
        //Get the selected movie and store it for movie details page
        FetchMovies.shared.selectedMovie = FetchMovies.shared.topRatedMovies[forRow]
        
        //Enable the user interaction and stop the activity indicator
        self.tabBarController?.view.isUserInteractionEnabled = true
        activityView.stopAnimating()
        
        //Instantiate and present the movie details view controller
        let destination = self.storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        self.navigationController!.pushViewController(destination, animated: true)

                
    }
    
}

