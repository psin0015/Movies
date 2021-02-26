//
//  MovieDetailViewController.swift
//  Movies
//
//  Created by Prashant Singh on 26/2/21.
//  Copyright © 2021 Prashant Singh. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    
    @IBOutlet weak var imageViewMoviePoster: UIImageView!
    @IBOutlet weak var labelMovieName: UILabel!
    @IBOutlet weak var labelAverageRating: UILabel!
    @IBOutlet weak var labelTotalVotes: UILabel!
    @IBOutlet weak var labelGenres: UILabel!
    @IBOutlet weak var labelReleaseDate: UILabel!
    @IBOutlet weak var labelMovieOverview: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup the navigation bar
        self.navigationItem.title = "Movie Details"
        
        //Fetch the movie details from the selected movie object and use them to populate the view
        if let selectedMovie = FetchMovies.shared.selectedMovie{
            
            //If movie poster is present then use it, else, show a default image
            if let largeImage = selectedMovie.largeImage{
                self.imageViewMoviePoster.image = largeImage
            }else{
                self.imageViewMoviePoster.image = UIImage(named: "movie")
            }
            
            self.labelMovieName.text = selectedMovie.title
            self.labelAverageRating.text = String(selectedMovie.rating)
            self.labelTotalVotes.text = String(selectedMovie.totalVotes)
            self.labelGenres.text = selectedMovie.genres.joined(separator: ", ")
            self.labelReleaseDate.text = selectedMovie.releaseDate
            self.labelMovieOverview.text = selectedMovie.overview
        }
    }
    
}
