//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by user on 08.04.2026.
//
import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, any Error>) -> Void) {
        let networkHandler: (Result<Data, Error>) -> Void = { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovie = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovie))
                } catch {
                    print("DECODE ERROR: \(error)")
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
        networkClient.fetch(url: mostPopularMoviesUrl, handler: networkHandler)
    }
}

