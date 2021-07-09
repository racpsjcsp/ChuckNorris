//
//  WebService.swift
//  ChuckNorris
//
//  Created by Rafael Plinio on 01/07/21.
//

import Foundation

class WebService {

    func getCategories(url: URL, completionHandler: @escaping (Category?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completionHandler(nil)
            } else if let data = data {
                let categories = try? JSONDecoder().decode(Category.self, from: data)
                if let categories = categories {
                    completionHandler(categories)
                }
                completionHandler(categories)
            }
        }.resume()
    }

    func getRandomJoke(url: URL, completionHandler: @escaping (JokeModel?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if response.statusCode >= 200 && response.statusCode <= 299 {
                        print("\(response.statusCode)")
                    } else {
                        print("somethig went wrong")
                    }
                }
            }
            if let error = error {
                print(error.localizedDescription)
                completionHandler(nil)
            } else if let data = data {
                let joke = try? JSONDecoder().decode(JokeModel.self, from: data)
                completionHandler(joke)
            }
        }.resume()
    }
    
    func getCategoryJoke(url: URL, completionHandler: @escaping (JokeModel?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completionHandler(nil)
            } else if let data = data {
                let joke = try? JSONDecoder().decode(JokeModel.self, from: data)
                completionHandler(joke)
            }
        }.resume()
    }
    
    func getKeywordJoke(url: URL, completionHandler: @escaping (KeywordJokeModel?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completionHandler(nil)
            } else if let data = data {
                let joke = try? JSONDecoder().decode(KeywordJokeModel.self, from: data)
                completionHandler(joke)
            }
        }.resume()
    }
}


