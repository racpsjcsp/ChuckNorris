//
//  CategorySelectionViewController.swift
//  ChuckNorris
//
//  Created by Rafael Plinio on 29/06/21.
//

import UIKit

protocol SetKeyworkOrCategoryDelegate {
    func setCategory(category: String)
    func setKeyword(keyword: String)
}

class CategorySelectionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    private var pickerData = [String]()
    private var pickerSelection = ""
    private var pickerDefaultValue = ""
    
    var delegate: SetKeyworkOrCategoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        getCategoryList()
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
    
    private func getCategoryList() {
        let categoryListURL = URL(string: "https://api.chucknorris.io/jokes/categories")!
            
        WebService().getCategories(url: categoryListURL) { categories in
            guard let categories = categories else { return }
        
            self.pickerData = categories
            self.pickerDefaultValue = self.pickerData.first!
            
            DispatchQueue.main.async {
                self.categoryPicker.reloadAllComponents()
                
                if let defaultValue = self.pickerData.first {
                    self.pickerDefaultValue = defaultValue
                }
            }
        }
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
    }
    
//MARK: - ButtonAction
    @IBAction func dismissVC(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        
        if categoryPicker.selectedRow(inComponent: 0) == 0 {
            pickerSelection = pickerDefaultValue
        }

        delegate?.setCategory(category: pickerSelection)
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        delegate?.setKeyword(keyword: searchTextField.text!)
    }
}
