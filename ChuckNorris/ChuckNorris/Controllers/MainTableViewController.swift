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
    private var numberOfJokes = 1
    private let selectedCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getRandomJokes()
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
        
        jokesToDisplay.removeAll()
        
        numberOfJokes = 1

        while numberOfJokes <= 10 {
            numberOfJokes += 1

            WebService().getJoke(url: jokeCategoryURL) { joke in
                guard let joke = joke else { return }
                
                while self.jokesToDisplay.count <= 10 {
                    self.jokesToDisplay.append(joke.value)
                }
                
                for _ in self.jokesToDisplay {
                    if self.jokesToDisplay.last == joke.value {
                        self.jokesToDisplay.removeLast()
                        self.numberOfJokes -= 1
                    }
                }
                                
                self.jokesToDisplay.append(joke.value)
                self.category = joke.categories
                
                self.jokesToDisplay.removeDuplicates()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
//
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
        cell.categorylabel.text = category.first?.capitalized
        
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
    func setKeyworkOrCategory(category: String) {
        dismiss(animated: true) {
            self.getJokesByCategory(jokeCategory: category)
        }
    }
}


