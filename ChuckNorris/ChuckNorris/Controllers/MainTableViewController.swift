//
//  MainTableViewController.swift
//  ChuckNorris
//
//  Created by Rafael Plinio on 29/06/21.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    let strings = ["testando label da custom cell...testando label da custom cell", "testando label da custom cell...testando label da custom cell, testando label da custom cell...testando label da custom cell, testando label da custom cell...testando label da custom cell,testando label da custom cell...testando label da custom cell"]
    
    private var categories = ["suspense", "technology", "political", "religion"]
    
    private var jokes = [String]()
    
    var selectedCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        print("viewDidLoad: \(selectedCategory)")
    }
    
    func getPickerSelectionData(data: String) {
        selectedCategory = data
        print(selectedCategory)
    }
    
    private func getJokes() {
        let url = "https://api.chucknorris.io/jokes/random?category=\(selectedCategory)"
        print("url: \(url)")
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is (httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            if let categories = try? JSONDecoder().decode(Category.self, from: data) {
                self.categories.append(contentsOf: categories)
                print("categories: \(self.categories)")
            }
            
            if let joke = try? JSONDecoder().decode(JokeModel.self, from: data) {
                self.jokes.append(joke.value)
                print("jokes: \(self.jokes)")
               
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                 
                }
            }
        }
        task.resume()
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
        return strings.count
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FactCell", for: indexPath) as? FactCell else {
            fatalError("FactCell not found")
        }
        
        cell.factLabel.text = strings[indexPath.row]
        
        let smallFont = UIFont.systemFont(ofSize: 15.0)
        let largeFont = UIFont.systemFont(ofSize: 25.0)

        cell.factLabel.font = largeFont
        
        if let factCharCount = cell.factLabel.text?.count {
            if factCharCount > 80 {
                cell.factLabel.font = smallFont
            }
        }
        
        cell.categorylabel.text = categories.shuffled()[indexPath.row]
        
        cell.shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        cell.shareButton.showsTouchWhenHighlighted = true
        
        return cell
    }

//MARK: - ButtonAction
    @objc func shareButtonTapped() {
        print("share button tapped")
    }
    

   
}


