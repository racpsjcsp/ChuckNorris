//
//  CategorySelectionViewController.swift
//  ChuckNorris
//
//  Created by Rafael Plinio on 29/06/21.
//

import UIKit

class CategorySelectionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    
    var pickerData = [String]()
    var pickerSelection = ""
    var pickerDefaultValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        getCategories()
        setupUI()
        setupPickerView()
    }
  
    
//MARK: - UI
    private func setupUI() {
        title = "Select Category"
    }
    
    private func setupPickerView() {
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
    private func getCategories() {
        let url = "https://api.chucknorris.io/jokes/categories"
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
                self.pickerData = categories
                self.pickerDefaultValue = self.pickerData.first!
                
                DispatchQueue.main.async {
                    
                    self.categoryPicker.reloadAllComponents()
                    
                    if let defaultValue = self.pickerData.first {
                        self.pickerDefaultValue = defaultValue
                        print(self.pickerDefaultValue)
                    }
                }
            }
        }
        task.resume()
    }
    
    
//MARK: - PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].capitalized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelection = pickerData[row]
        print("pickerSelection inside didSelectRow: \(pickerSelection)")
    }
    
//MARK: - ButtonAction
    @IBAction func dismissVC(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        if let navController = presentingViewController as? UINavigationController {
            let vc = navController.topViewController as! MainTableViewController
            vc.selectedCategory = pickerSelection
            
            if categoryPicker.selectedRow(inComponent: 0) == 0 {
                vc.selectedCategory = pickerDefaultValue
            }
            
            print("selectedCategory inside doneButtonPressed: \(vc.selectedCategory)")
        }
        
        dismiss(animated: true, completion: nil)
    }
}
