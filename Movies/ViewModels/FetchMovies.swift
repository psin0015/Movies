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
}


class FetchMovies: NSObject {

    static let shared = FetchMovies()
    
    private override init() {}
    
    let API_KEY: String = "253501da2d60bcb7ac0af066641c69a2"
    lazy var TOP_RATED_URL : String  = { return "https://api.themoviedb.org/3/movie/top_rated?api_key=\(API_KEY)&language=en-US&page=1"}()
    
    lazy var UPCOMING_URL : String  = {return "https://api.themoviedb.org/3/movie/upcoming?api_key=\(API_KEY)&language=en-US&page=1"}()

    lazy var GENRE_URL : String  = {return "https://api.themoviedb.org/3/genre/movie/list?api_key=\(API_KEY)&language=en-US"}()
    
    lazy var IMAGE_SMALL_BASE_URL : String  = {return "https://image.tmdb.org/t/p/w92/"}()
    
    
    var topRatedMovies : [Movie] = []
    var upcomingMovies : [Movie] = []
    
    var fetchMoviesDelegate : FetchMoviesDelegate?
    //var upcomingDelegate : UpcomingMoviesDelegate?
    
    var genreDetails: Dictionary<Int, String> = [:]
    
    func fetchTopRatedMovies(){
        
        if(!topRatedMovies.isEmpty){
            
            fetchMoviesDelegate?.didFetchMovies()
            
        }else if (genreDetails.isEmpty){
            
            fetchGenreDetails()
            
        }else{
            
            guard let url = URL(string: TOP_RATED_URL)
                else
            {
                return
            }
            
            //create task object using url session
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                //initialise dataresponse if there is data received using the url
                guard let dataResponse = data,
                    error == nil else {
                        return
                }
                do{
                    
                    if let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: []) as? [String:Any]{
                        
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
    
    func fetchGenreDetails(){
        
        guard let url = URL(string: GENRE_URL)
            else
        {
            return
        }
        
        //create task object using url session
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            //initialise dataresponse if there is data received using the url
            guard let dataResponse = data,
                error == nil else {
                    return
            }
            do{
                
                if let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: []) as? [String:Any]{
                    
                    if let genreArray = jsonResponse["genres"] as? [[String : Any]]{
                        for genreDictionary in genreArray{
                            
                            let genreId = genreDictionary["id"] as? Int
                            let genreName = genreDictionary["name"] as? String
                            
                            self.genreDetails[genreId ?? 0] = genreName ?? ""
                        }
                    }
                    
                    
                    if(!self.genreDetails.isEmpty){
                    
                        self.fetchTopRatedMovies()
                    }else{
                        return
                    }
                    
                }
                
                                
            } catch let parsingError {
                print("Error", parsingError)
            }
            
        }
        // Start the data task
        task.resume()
        
        
    }
    
    func fetchUpcomingMovies(){
        
        if(!upcomingMovies.isEmpty){
            fetchMoviesDelegate?.didFetchMovies()
        }else{
            
            guard let url = URL(string: UPCOMING_URL)
                else
            {
                return
            }
            
            //create task object using url session
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                //initialise dataresponse if there is data received using the url
                guard let dataResponse = data,
                    error == nil else {
                        return
                }
                do{
                    
                    if let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: []) as? [String:Any]{
                        
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
    
    
    func populateMoviesForResponse(movieList: inout [Movie], jsonResponse:[String:Any]){
        
        
        if let movieResultsArray = jsonResponse["results"] as? [[String : Any]]{
            
            for movieResult in movieResultsArray{
                
                let genreIds = movieResult["genre_ids"] as? [Int]
                let title = movieResult["title"] as? String ?? ""
                let rating = movieResult["vote_average"] as? Double ?? 0.0
                let totalVotes = movieResult["vote_count"] as? Int ?? 0
                let overview = movieResult["overview"] as? String ?? ""
                let releaseDate = movieResult["release_date"] as? String ?? ""
                let posterPath = movieResult["poster_path"] as? String ?? ""
                var smallImage: UIImage = UIImage(named: "movie") ?? UIImage()
                
                
                if let url = URL(string: IMAGE_SMALL_BASE_URL+posterPath){
                   
                    if let data = try? Data(contentsOf: url){
                        smallImage = UIImage(data: data) ?? UIImage()
                    }
                }
                
                let largeImage: UIImage = UIImage(named: "movie") ?? UIImage()
                
                var genres:[String] = []
                
                if(!(genreIds?.isEmpty ?? true)){
                    for genreID in genreIds!{
                        genres.append(self.genreDetails[genreID] ?? "")
                    }
                }
                
                movieList.append(Movie(title: title, rating: rating, totalVotes: totalVotes, overview: overview, releaseDate: releaseDate, posterPath: posterPath, genres: genres,smallImage: smallImage, largeImage: largeImage))
            }
        }
        
        DispatchQueue.main.async {
            self.fetchMoviesDelegate?.didFetchMovies()
        }
    }
    
}
