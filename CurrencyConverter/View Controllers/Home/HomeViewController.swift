//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Camilo Cabana on 18/11/19.
//  Copyright © 2019 Camilo Cabana. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var amountToChangeTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var exchangeRatesCollectionView: UICollectionView!
    @IBOutlet weak var topContainerView: UIView!
    
    var selectedCurrencyIndex: Int = 0
    var currencyConversions: [Double] = []
    var currencies: [Currency] = []
    var amountToExchange: Double {
        guard let amount = Double(amountToChangeTextField.text ?? "") else { return 0 }
        return amount
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topContainerView.layer.cornerRadius = 8
        amountToChangeTextField.becomeFirstResponder()
        downloadCurrenciesData()
        createCurrencyPicker()
        createCurrencyToolBar()
        createMoneyToExchhangeToolBar()
        amountToChangeTextField.keyboardType = .decimalPad
        Timer.scheduledTimer(timeInterval: 30 * 60, target: self, selector: #selector(refreshCurrencyData), userInfo: nil, repeats: true)
    }
    
    @objc func refreshCurrencyData() {
            downloadCurrenciesData()
        }
        
        func downloadCurrenciesData() {
            guard let url = URL(string: "http://www.apilayer.net/api/live?access_key=a3bdebe883682fda1fb294fe9f4732e2") else { return }
            let session = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let urlData = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: urlData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        if let rates = json["quotes"] as? [String: Double] {
                            var downloadedCurrencies: [Currency] = []
                            for (currencySymbol, currencyRate) in rates {
                                downloadedCurrencies.append(Currency(symbol: currencySymbol.replacingCharacters(in: currencySymbol.startIndex...currencySymbol.index(currencySymbol.startIndex, offsetBy: 2), with: ""), rate: currencyRate))
                            }
                            self.currencies = downloadedCurrencies.sorted { $0.symbol < $1.symbol }
                        }
                    } catch { }
                }
            }
            session.resume()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            exchangeRatesCollectionView.reloadData()
        }
    }

    extension HomeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return currencies.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return currencies[row].symbol
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedCurrencyIndex = row
            currencyTextField.text = currencies[row].symbol
        }
        
        func createCurrencyPicker() {
            let currencyPicker = UIPickerView()
            currencyPicker.delegate = self
            currencyTextField.inputView = currencyPicker
        }
        
        func createCurrencyToolBar() {
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(previousTextField))
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            toolBar.setItems([backButton,space,doneButton], animated: true)
            toolBar.isUserInteractionEnabled = true
            currencyTextField.inputAccessoryView = toolBar
        }
        
        func createMoneyToExchhangeToolBar() {
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTextField))
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            toolBar.setItems([space,nextButton], animated: true)
            toolBar.isUserInteractionEnabled = true
            amountToChangeTextField.inputAccessoryView = toolBar
        }
        
        @objc func done() {
            currencyConversions.removeAll()
            if currencyTextField.text != "" && amountToChangeTextField.text != "" {
                currencies.forEach {
                    currencyConversions.append(amountToExchange * ($0.rate / currencies[selectedCurrencyIndex].rate))
                }
                exchangeRatesCollectionView.reloadData()
                view.endEditing(true)
            } else if currencyTextField.text != "" && amountToChangeTextField.text == "" {
                alert(title: "Hello!!", message: "Please add an amount to exchange.")
            } else if currencyTextField.text == "" && amountToChangeTextField.text != "" {
                alert(title: "Hello!!", message: "Please select a currency.")
            } else if currencyTextField.text == "" && amountToChangeTextField.text == "" {
                alert(title: "Hello!!", message: "Please add currency and value.")
            }
        }
        
        @objc func nextTextField() {
            guard amountToChangeTextField.text != "" else {
                alert(title: "Hello!!", message: "Please add an amount to exchange.")
                return
            }
            currencyTextField.becomeFirstResponder()
        }
        
        @objc func previousTextField() {
            amountToChangeTextField.becomeFirstResponder()
        }
        
        func alert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true)
        }

    }

    extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return currencyConversions.count
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (collectionView.frame.size.width - 24) / 3, height: 80)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 20
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExchangeRateCollectionViewCell", for: indexPath) as! ExchangeRateCollectionViewCell
            cell.symbolLabel.text = currencies[indexPath.row].symbol
            cell.valueLabel.text = String(format: "%.2f", currencyConversions[indexPath.row])
            return cell
        }

}

