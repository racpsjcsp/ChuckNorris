//
//  MainTableViewController.swift
//  ChuckNorris
//
//  Created by Rafael Plinio on 29/06/21.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    private var categories = [Category]()
    private var category = [String]()
    private var joke = ""
    private var jokes = [String]()
    private var numberOfJokes = 1
    
    var selectedCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        print("viewDidLoad: \(selectedCategory)")
        
        getRandomJoke()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func getPickerSelectionData(data: String) {
        selectedCategory = data
        print(selectedCategory)
    }
    
    private func getRandomJoke() {
        let randomJokeURL = URL(string: "https://api.chucknorris.io/jokes/random")!
        
        while numberOfJokes <= 10 {
            
            numberOfJokes += 1
            
            WebService().getJoke(url: randomJokeURL) { joke in
                guard let joke = joke else { return }
               
                self.jokes.append(joke.value)
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
        return jokes.count
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FactCell", for: indexPath) as? FactCell else {
            fatalError("FactCell not found")
        }
        
        cell.factLabel.text = jokes[indexPath.row]
        cell.categorylabel.text = category.first
        
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


