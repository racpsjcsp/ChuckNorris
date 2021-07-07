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

class CategorySelectionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    private var pickerData = [String]()
    private var pickerSelection = ""
    private var pickerDefaultValue = ""
    
    var delegate: SetKeyworkOrCategoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Category"
        searchTextField.delegate = self

        getCategoryList()
        setupPickerView()
        
        disableSearchButton()
    }
    

//MARK: - Alert
    private func showKeywordAlert() {
        let alert = UIAlertController(title: "Invalid Keyword", message: "The keyword cannot contain any symbol, number or space.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        self.present(alert, animated: true)
    }

    
//MARK: - TextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = (searchTextField.text! as NSString).replacingCharacters(in: range, with: string)

        if text.range(of: ".*[^\\A-Za-z].*", options: .regularExpression) != nil {
            showKeywordAlert()
        }
        
        if text.isEmpty || text.count < 3{
            disableSearchButton()
        } else {
            enableSearchButton()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        delegate?.setKeyword(keyword: searchTextField.text!)
        return true
    }
    

//MARK: - API Categories
    
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
    
    private func setupPickerView() {
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
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
    

//MARK: - Button
    private func disableSearchButton() {
        searchButton.isUserInteractionEnabled = false
        searchButton.isEnabled = false
        searchButton.alpha = 0.5
    }
    
    private func enableSearchButton() {
        searchButton.isUserInteractionEnabled = true
        searchButton.isEnabled = true
        searchButton.alpha = 1
    }
    
    
//MARK: - ButtonActions
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
