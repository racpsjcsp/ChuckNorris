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
    private var randomJokes = [String]()
    private var jokeModel = [JokeModel]()
    private var urlFact = [String]()
    private var factToShare = [Int:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkIfLaunchedBefore()
    }
        
    
//MARK: - UserDefaults
    
    private func checkIfLaunchedBefore() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            getRandomJokes()
        } else {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            showFirstTimeAlert()
        }
    }
    
//MARK: - Alert
    
    private func showFirstTimeAlert() {
        let alertTitle = "Welcome to Chuck Norris Facts"
        let alertMessage = "Click on the search icon on the top right corner to search for Chuck Norris Facts based on a list of categories or a keyword of your choice!"
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
//MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectCategorySegue" {
            let controller = segue.destination as! UINavigationController
            guard let targetVC = controller.topViewController as? CategorySelectionViewController else { return }
            targetVC.delegate = self
        }
    }
    
    
//MARK: - Fetching Data
    
    private func getRandomJokes() {
        let randomJokeURL = URL(string: "https://api.chucknorris.io/jokes/random")!
        var numberOfJokes = 1
        
        randomJokes.removeAll()
        jokesToDisplay.removeAll()
        category.removeAll()
        urlFact.removeAll()
        
        while numberOfJokes <= 10 {
            
            numberOfJokes += 1
            
            WebService().getRandomJoke(url: randomJokeURL) { joke in
                guard let joke = joke else { return }
               
                self.randomJokes.append(joke.value)
                self.category.append(contentsOf: joke.categories)
                self.urlFact.append(joke.url)
                
                if joke.categories .isEmpty {
                    self.category.append("UNCATEGORIZED")
                }
                
                self.randomJokes.removeDuplicates()
                self.jokesToDisplay = self.randomJokes
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func getJokesByCategory(jokeCategory: String) {
        let jokeCategoryURL = URL(string: "https://api.chucknorris.io/jokes/random?category=\(jokeCategory)")!
        var numberOfJokes = 1
        
        categoryJokes.removeAll()
        jokesToDisplay.removeAll()
        category.removeAll()
        urlFact.removeAll()

        while numberOfJokes <= 10 {
            numberOfJokes += 1

            WebService().getCategoryJoke(url: jokeCategoryURL) { joke in
                guard let joke = joke else { return }
                                
                for _ in self.categoryJokes {
                    if self.categoryJokes.last == joke.value {
                        self.categoryJokes.removeLast()
                        numberOfJokes -= 1
                    }
                }
                                
                self.categoryJokes.append(joke.value)
                self.category.append(contentsOf: joke.categories)
                self.urlFact.append(joke.url)
                
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
        urlFact.removeAll()
        
        WebService().getKeywordJoke(url: jokeKeywordURL) { joke in
            guard let joke = joke else { return }

            self.jokeModel = joke.result

            for item in self.jokeModel {
                self.keywordJokes.append(item.value)
                self.urlFact.append(item.url)

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

        cell.shareButton.tag = indexPath.row

        factToShare[indexPath.row] = urlFact[indexPath.row]
        
        return cell
    }


//MARK: - ButtonAction
    
    @objc func shareButtonTapped(sender: UIButton) {
        
        let jokeToShare = jokesToDisplay[sender.tag]
        
        guard let url = factToShare[sender.tag] else { return }

        let sharedObject = [jokeToShare, url]
        let activityViewController = UIActivityViewController(activityItems: sharedObject, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view

        self.present(activityViewController, animated: true, completion: nil)
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


