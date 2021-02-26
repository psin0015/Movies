//
//  FetchMovies.swift
//  Movies
//
//  Created by Prashant Singh on 25/2/21.
//  Copyright © 2021 Prashant Singh. All rights reserved.
//

import UIKit

protocol FetchMoviesDelegate {
    func didFetchMovies()
    func didDownloadPosterImage(forRow:Int)
}


class FetchMovies: NSObject {
    
    //Creating shared instance of Fetch Movies
    static let shared = FetchMovies()
    
    //Making initialiser private to avoid multiple instantiation
    private override init() {}
    
    
    let API_KEY: String = "YOUR API KEY HERE"
    
    //Creating URL Strings depending upon request type
    lazy var TOP_RATED_URL : String  = { return "https://api.themoviedb.org/3/movie/top_rated?api_key=\(API_KEY)&language=en-US&page=1"}()
    
    lazy var UPCOMING_URL : String  = {return "https://api.themoviedb.org/3/movie/upcoming?api_key=\(API_KEY)&language=en-US&page=1"}()
    
    lazy var GENRE_URL : String  = {return "https://api.themoviedb.org/3/genre/movie/list?api_key=\(API_KEY)&language=en-US"}()
    
    lazy var IMAGE_SMALL_BASE_URL : String  = {return "https://image.tmdb.org/t/p/w92/"}()
    
    lazy var IMAGE_LARGE_BASE_URL : String  = {return "https://image.tmdb.org/t/p/w300/"}()
    
    
    //Declaring and initialising two empty lists
    var topRatedMovies : [Movie] = []
    var upcomingMovies : [Movie] = []
    
    //It stores the movie that is chosen for its details
    var selectedMovie : Movie?
    
    //Delegate for data binding
    var fetchMoviesDelegate : FetchMoviesDelegate?
    
    //Declaring and initialising an empty dictionary to store movie genre code and its corresponding name. The API returns only the genre id in the top-rated and upcoming movies response.
    var genreDetails: Dictionary<Int, String> = [:]
    
    
    //Function to fetch the top rated movies
    func fetchTopRatedMovies(){
        
        //Check whether the top rated movies have already been fetched. If yes then inform the view controller by calling the delegate method
        if(!topRatedMovies.isEmpty){
            
            fetchMoviesDelegate?.didFetchMovies()
            
            //Check whether the genre id and value details are present in the dictionary or not. If they are not present then fetch them from the API.
        }else if (genreDetails.isEmpty){
            
            fetchGenreDetails()
            
        }else{
            
            //Create url instance using url string
            guard let url = URL(string: TOP_RATED_URL)
                else
            {
                return
            }
            
            //Create data task object using url session
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                //Initialise dataResponse if there is data received using the url
                guard let dataResponse = data,
                    error == nil else {
                        return
                }
                do{
                    
                    //Transform the data response into dictionary
                    if let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: []) as? [String:Any]{
                        
                        //Populate the top rated movies list using the json response object
                        self.populateMoviesForResponse(movieList:&self.topRatedMovies, jsonResponse:jsonResponse)
                        
                    }
                    
                    
                } catch let parsingError {
                    print("Error", parsingError)
                }
                
            }
            // Start the data task
            task.resume()
            
        }
        
    }
    
    //Fetch the genre details from the API
    func fetchGenreDetails(){
        
        //Create url instance using url string
        guard let url = URL(string: GENRE_URL)
            else
        {
            return
        }
        
        //Create task object using url session
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            //Initialise dataresponse if there is data received using the url
            guard let dataResponse = data,
                error == nil else {
                    return
            }
            do{
                
                //Transform the data response into dictionary
                if let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: []) as? [String:Any]{
                    
                    if let genreArray = jsonResponse["genres"] as? [[String : Any]]{
                        for genreDictionary in genreArray{
                            
                            let genreId = genreDictionary["id"] as? Int
                            let genreName = genreDictionary["name"] as? String
                            
                            //Add the genre id and genre name into the dictionary if genreId or genreName is present, else, add a default value.
                            self.genreDetails[genreId ?? 0] = genreName ?? ""
                        }
                    }
                }
                
            } catch let parsingError {
                print("Error", parsingError)
            }
            
            //If the conversion was successful, then, fetch the top rated movies.
            if(!self.genreDetails.isEmpty){
                
                self.fetchTopRatedMovies()
            }else{
                return
            }
        }
        // Start the data task
        task.resume()
        
        
    }
    
    func fetchUpcomingMovies(){
        
        //Check whether the upcoming movies have already been fetched. If yes then inform the view controller by calling the delegate method
        if(!upcomingMovies.isEmpty){
            fetchMoviesDelegate?.didFetchMovies()
        }else{
            
            //Create url instance using url string
            guard let url = URL(string: UPCOMING_URL)
                else
            {
                return
            }
            
            //Create task object using url session
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                //Initialise dataresponse if there is data received using the url
                guard let dataResponse = data,
                    error == nil else {
                        return
                }
                do{
                    //Transform the data response into dictionary
                    if let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: []) as? [String:Any]{
                        
                        //Populate the top rated movies list using the json response object
                        self.populateMoviesForResponse(movieList:&self.upcomingMovies, jsonResponse:jsonResponse)
                        
                    }
                    
                } catch let parsingError {
                    print("Error", parsingError)
                }
                
            }
            // Start the data task
            task.resume()
        }
    }
    
    //Parse the toprated movies or upcoming movies response and add it to the corresponding movie list depending upon the passed movie list in the parameter.
    func populateMoviesForResponse(movieList: inout [Movie], jsonResponse:[String:Any]){
        
        
        if let movieResultsArray = jsonResponse["results"] as? [[String : Any]]{
            
            //Fetch the movies details from the dictionary. If it is not present, then give a default value.
            for movieResult in movieResultsArray{
                
                let genreIds = movieResult["genre_ids"] as? [Int]
                let title = movieResult["title"] as? String ?? ""
                let rating = movieResult["vote_average"] as? Double ?? 0.0
                let totalVotes = movieResult["vote_count"] as? Int ?? 0
                let overview = movieResult["overview"] as? String ?? ""
                let releaseDate = movieResult["release_date"] as? String ?? ""
                let posterPath = movieResult["poster_path"] as? String ?? ""
                var smallImage: UIImage = UIImage(named: "movie") ?? UIImage()
                
                //Fetch the movie poster image icon from the API
                if let url = URL(string: IMAGE_SMALL_BASE_URL+posterPath){
                    
                    if let data = try? Data(contentsOf: url){
                        smallImage = UIImage(data: data) ?? UIImage()
                    }
                }
                
                var genres:[String] = []
                
                //Populate movie genres from the genre dictionary if genres are received in the response
                if(!(genreIds?.isEmpty ?? true)){
                    for genreID in genreIds!{
                        genres.append(self.genreDetails[genreID] ?? "")
                    }
                }
                
                //Create movie object and add it to the topmovies or the upcoming movies list
                movieList.append(Movie(title: title, rating: rating, totalVotes: totalVotes, overview: overview, releaseDate: releaseDate, posterPath: posterPath, genres: genres,smallImage: smallImage))
            }
        }
        
        //Inform the view controller after the operation has been finished on the main theread.
        DispatchQueue.main.async {
            self.fetchMoviesDelegate?.didFetchMovies()
        }
    }
    
    //Download the large movie poster image for the movie details screen.
    func downloadPosterImage(forRow:Int, forTopRatedMovies:Bool){
        
        //Check whether the poster image has already been downloaded earlier
        if(forTopRatedMovies && self.topRatedMovies[forRow].largeImage != nil){
            self.fetchMoviesDelegate?.didDownloadPosterImage(forRow: forRow)
        }else if (!forTopRatedMovies && self.upcomingMovies[forRow].largeImage != nil){
            self.fetchMoviesDelegate?.didDownloadPosterImage(forRow: forRow)
        }else{
            
            //Get the poster path depending upon whether it is requested for top movies or upcoming movies.
            let posterPath = forTopRatedMovies ? self.topRatedMovies[forRow].posterPath : self.upcomingMovies[forRow].posterPath
            
            //Fetch the movie poster image from the API
            if let url = URL(string: IMAGE_LARGE_BASE_URL+posterPath){
                
                if let data = try? Data(contentsOf: url){
                    let largeImage = UIImage(data: data)
                    
                    //Store the image details into the requested movie list
                    if(forTopRatedMovies){
                        self.topRatedMovies[forRow].largeImage = largeImage
                    }else{
                        self.upcomingMovies[forRow].largeImage = largeImage
                    }
                    
                }
                
                //Inform the view controller after the operation has been finished on the main theread.
                DispatchQueue.main.async {
                    self.fetchMoviesDelegate?.didDownloadPosterImage(forRow: forRow)
                }
            }
        }
        
        
        
    }
    
}
