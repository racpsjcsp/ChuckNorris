//
//  WebService.swift
//  ChuckNorris
//
//  Created by Rafael Plinio on 01/07/21.
//

import Foundation

class WebService {
    func getCategories(url: URL, completionHandler: @escaping ([Category]?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completionHandler(nil)
            } else if let data = data {
                let categories = try? JSONDecoder().decode([Category].self, from: data)
                if let categories = categories {
                    completionHandler(categories)
                }
                completionHandler(categories)
            }
            
        }.resume()
    }

    func getJoke(url: URL, completionHandler: @escaping (JokeModel?) -> ()) {
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
}


