//
//  Movie.swift
//  Movies
//
//  Created by Prashant Singh on 25/2/21.
//  Copyright © 2021 Prashant Singh. All rights reserved.
//

import UIKit

class Movie: NSObject {

    //Keeping largeImage optional as it is downloaded only when the movie details view is loaded
    var title: String
    var rating: Double
    var totalVotes: Int
    var overview: String
    var releaseDate: String
    var posterPath: String
    var genres: [String]
    var smallImage: UIImage
    var largeImage:UIImage?
    

    public init(title: String, rating: Double, totalVotes: Int, overview: String, releaseDate: String, posterPath: String, genres: [String], smallImage:UIImage) {
        self.title = title
        self.rating = rating
        self.totalVotes = totalVotes
        self.overview = overview
        self.releaseDate = releaseDate
        self.posterPath = posterPath
        self.genres = genres
        self.smallImage = smallImage        
        
    }
}
