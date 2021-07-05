//
//  MainTableViewController.swift
//  ChuckNorris
//
//  Created by Rafael Plinio on 29/06/21.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    private var category = [String]()
    private var jokesToDisplay = [String]()
    private var categoryJokes = [String]()
    private var keywordJokes = [String]()
    private var jokeModel = [JokeModel]()
    private var numberOfJokes = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
////        getRandomJokes()
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectCategorySegue" {
            let controller = segue.destination as! UINavigationController//CategorySelectionViewController
            guard let targetVC = controller.topViewController as? CategorySelectionViewController else { return }
            targetVC.delegate = self
        }
    }
    
    private func getRandomJokes() {
        let randomJokeURL = URL(string: "https://api.chucknorris.io/jokes/random")!
        
        while numberOfJokes <= 10 {
            
            numberOfJokes += 1
            
            WebService().getJoke(url: randomJokeURL) { joke in
                guard let joke = joke else { return }
               
                self.jokesToDisplay.append(joke.value)
                self.category = joke.categories
                if joke.categories .isEmpty {
                    self.category.append("UNCATEGORIZED")
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func getJokesByCategory(jokeCategory: String) {
        let jokeCategoryURL = URL(string: "https://api.chucknorris.io/jokes/random?category=\(jokeCategory)")!
        
        categoryJokes.removeAll()
        jokesToDisplay.removeAll()
        category.removeAll()
        
        numberOfJokes = 1

        while numberOfJokes <= 10 {
            numberOfJokes += 1

            WebService().getCategoryJoke(url: jokeCategoryURL) { joke in
                guard let joke = joke else { return }
                
                while self.categoryJokes.count <= 10 {
                    self.categoryJokes.append(joke.value)
                }
                
                for _ in self.categoryJokes {
                    if self.categoryJokes.last == joke.value {
                        self.categoryJokes.removeLast()
                        self.numberOfJokes -= 1
                    }
                }
                                
                self.categoryJokes.append(joke.value)
                self.category.append(contentsOf: joke.categories)
                
                self.categoryJokes.removeDuplicates()
                self.jokesToDisplay = self.categoryJokes
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    private func getJokesByKeyword(jokeKeyword: String) {
        let jokeKeywordURL = URL(string: "https://api.chucknorris.io/jokes/search?query=\(jokeKeyword)")!

        keywordJokes.removeAll()
        jokesToDisplay.removeAll()
        category.removeAll()
        
        
        WebService().getKeywordJoke(url: jokeKeywordURL) { joke in
            guard let joke = joke else { return }

            self.jokeModel = joke.result

            for item in self.jokeModel {
                self.keywordJokes.append(item.value)
                if item.categories == [] {
                    self.category.append("uncategorized")
                } else {
                    self.category.append(contentsOf: item.categories)
                }
            }

            for item in self.jokeModel {
                if self.keywordJokes.last == item.value {
                    self.keywordJokes.removeLast()
                }
            }

            self.keywordJokes.removeDuplicates()
            self.jokesToDisplay = self.keywordJokes
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.tableView.reloadData()
            }
            
        }
    }
    
//MARK: - UI
        
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Chuck Norris Facts"
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
    }
        
//MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jokesToDisplay.count
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FactCell", for: indexPath) as? FactCell else {
            fatalError("FactCell not found")
        }
        
        cell.factLabel.text = jokesToDisplay[indexPath.row]
        cell.categorylabel.text = category[indexPath.row].uppercased()
        
        let smallFont = UIFont.systemFont(ofSize: 15.0)
        let largeFont = UIFont.systemFont(ofSize: 25.0)

        cell.factLabel.font = largeFont
        
        if let factCharCount = cell.factLabel.text?.count {
            if factCharCount > 80 {
                cell.factLabel.font = smallFont
            }
        }
        
        cell.shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        cell.shareButton.showsTouchWhenHighlighted = true
        
        return cell
    }

//MARK: - ButtonAction
    
    @objc func shareButtonTapped() {
        print("share button tapped")
    }
   
}


//MARK: - Extensions

extension MainTableViewController: SetKeyworkOrCategoryDelegate {
    func setCategory(category: String) {
        dismiss(animated: true) {
            self.getJokesByCategory(jokeCategory: category)
        }
    }
    
    func setKeyword(keyword: String) {
        dismiss(animated: true) {
            self.getJokesByKeyword(jokeKeyword: keyword)
        }
    }
}


