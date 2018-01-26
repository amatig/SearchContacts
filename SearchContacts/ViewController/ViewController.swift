//
//  ViewController.swift
//  TestSwift
//
//  Created by Giovanni Amati on 22/11/2017.
//  Copyright © 2017 Messagenet. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mainTableView: UITableView!
    
    private var currentSelection: [String: String] = [:]
    
    private var keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"];
    private var keysABC = ["", "ABC", "DEF", "GHI", "JKL", "MNO", "PQRS", "TUV", "WXYZ", "", "+", ""];
    private var keysREGEX = ["", "(A|B|C)", "(D|E|F)", "(G|H|I)", "(J|K|L)", "(M|N|O)", "(P|Q|R|S)", "(T|U|V)", "(W|X|Y|Z)", "", "", ""];
    
    private var fetchRegexName: String = ""
    private var fetchRegexNumber: String = ""
    private var dataSource: NSArray = []
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mainTableView.separatorStyle = .none
        
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchBar.delegate = self
        
        ContactsUtils.shared().checkPermission { (granted, error) in
            
            if granted {
                ContactsUtils.shared().refresh(completion: { (done) in
                    
                    if done {
                        
                        self.dataSource = ContactsUtils.shared().getAllContacts(predicate: nil)
                        self.refreshTable()
                        
                    }
                    
                })
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeCall(formatedNumber: String) {
        let phoneUrl = "tel://\(formatedNumber)"
        let url:NSURL = NSURL(string: phoneUrl)!
        appDelegate.openURL(url as URL)
    }
    
    // MARK: - searchBar Delegate
    
    func calculateRegexNumberWith(number: String) -> String {
        var regex = ""
        
        if number.count > 0 {
            for i in 0...number.count {
                if let c = number.characterAtIndex(index: i) {
                    let part = String(c)
                    var sep = ""
                    if i < number.count - 1 {
                        sep = "( )*"
                    }
                    regex = "\(regex)\(part)\(sep)"
                }
            }
        }
        
        return regex
    }
    
    func calculateRegexNameWith(number: String) -> String {
        var regex = "^"
        
        if number.count > 0 {
            for i in 0...number.count {
                if let c = number.characterAtIndex(index: i) {
                    let stringa = String(c)
                    let index = self.keys.index(of: stringa) ?? self.keys.count
                    if index < self.keys.count {
                        let part = self.keysREGEX[index]
                        if part.count > 0 {
                            var sep = ""
                            if i < number.count - 1 {
                                sep = "( )*"
                            }
                            regex = "\(regex)\(part)\(sep)"
                        }
                        
                    }
                }
            }
        }
        if regex.count > 0 {
            regex = ".*\(regex).*"
        }
        
        return regex
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.fetchRegexName = self.calculateRegexNameWith(number: searchText)
        self.fetchRegexNumber = self.calculateRegexNumberWith(number: searchText)
        
        let fetchRegexNumberE164 = (self.fetchRegexNumber as NSString).replacingOccurrences(of: "( )*", with: "")
        
        if fetchRegexNumberE164.contains("0") || fetchRegexNumberE164.contains("1") ||
            fetchRegexNumberE164.contains("+") || fetchRegexNumberE164.contains("*") || fetchRegexNumberE164.contains("#") {
            
            self.fetchRegexName = ""
        }
        
        // print("Search name " + self.fetchRegexName)
        // print("Search number " + fetchRegexNumberE164)
        
        let predicate = NSPredicate(format: "number CONTAINS[cd] %@ OR givenName MATCHES[cd] %@ OR familyName MATCHES[cd] %@ OR fullName MATCHES[cd] %@", fetchRegexNumberE164, self.fetchRegexName, self.fetchRegexName, self.fetchRegexName)
        self.dataSource = ContactsUtils.shared().getAllContacts(predicate: predicate)
        
        self.refreshTable()
    }
    
    // MARK: - tableView Delegate and DataSource
    
    func refreshTable() {
        DispatchQueue.main.async {
            
            self.mainTableView.reloadData()
            
            let n = self.mainTableView.numberOfRows(inSection: 0)
            if n > 0 {
                let topPath = NSIndexPath.init(row: 0, section: 0) as IndexPath
                self.mainTableView.scrollToRow(at: topPath, at: .top, animated: false)
            }
            
        }
    }
    
    func restyleNameLabel(label: UILabel?, givenName: String?, familyName: String?, fullName: String?) {
        if label != nil {
            
            let fetchRegexNameTmp = self.fetchRegexName.replacingOccurrences(of: ".*", with: "", options: .literal, range: nil)
            
            if fetchRegexNameTmp.count > 0 {
                let attrs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: label!.font.pointSize)]
                let subAttrs = [NSAttributedStringKey.foregroundColor: UIColor.black,
                                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: label!.font.pointSize)]
                
                var found = false
                let attributedText = NSMutableAttributedString()
                
                var attributedText1: NSMutableAttributedString?
                if givenName != nil && givenName!.count > 0 {
                    let range = givenName!.range(of: fetchRegexNameTmp, options: [.caseInsensitive, .regularExpression])
                    if range != nil {
                        found = true
                        
                        attributedText1 = NSMutableAttributedString.init(string: givenName!, attributes: attrs)
                        attributedText1?.setAttributes(subAttrs, range: range!.nsRange)
                    } else {
                        attributedText1 = NSMutableAttributedString.init(string: givenName!, attributes: attrs)
                    }
                }
                
                var attributedText2: NSMutableAttributedString?
                if familyName != nil && familyName!.count > 0 {
                    let range = familyName!.range(of: fetchRegexNameTmp, options: [.caseInsensitive, .regularExpression])
                    if range != nil {
                        found = true
                        
                        attributedText2 = NSMutableAttributedString.init(string: familyName!, attributes: attrs)
                        attributedText2?.setAttributes(subAttrs, range: range!.nsRange)
                    } else {
                        attributedText2 = NSMutableAttributedString.init(string: familyName!, attributes: attrs)
                    }
                }
                
                if found {
                    if attributedText1 != nil {
                        attributedText.append(attributedText1!)
                    }
                    if attributedText2 != nil {
                        if attributedText1 != nil {
                            attributedText.append(NSMutableAttributedString.init(string: " "))
                        }
                        attributedText.append(attributedText2!)
                    }
                } else {
                    var attributedText3: NSMutableAttributedString?
                    let range = fullName!.range(of: fetchRegexNameTmp, options: [.caseInsensitive, .regularExpression])
                    if (range != nil) {
                        found = true
                        
                        attributedText3 = NSMutableAttributedString.init(string: fullName!, attributes: attrs)
                        attributedText3?.setAttributes(subAttrs, range: range!.nsRange)
                        
                        attributedText.append(attributedText3!)
                    }
                }
                
                if (found) {
                    label!.attributedText = attributedText
                    
                    return
                }
            }
            
            label!.text = fullName
            
        }
    }
    
    func restyleNumberLabel(label: UILabel?, number: String?) {
        if label != nil {
            
            var fetchRegexNumberTmp = self.fetchRegexNumber.replacingOccurrences(of: "( )*", with: "[\\ \\-\\(\\)]*", options: .literal, range: nil)
            fetchRegexNumberTmp = fetchRegexNumberTmp.replacingOccurrences(of: "+", with: "\\+", options: .literal, range: nil)
            
            if fetchRegexNumberTmp.count > 0 {
                let attrs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: label!.font.pointSize)]
                let subAttrs = [NSAttributedStringKey.foregroundColor: UIColor.black,
                                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: label!.font.pointSize)]
                
                let range = number!.range(of: fetchRegexNumberTmp, options: [.caseInsensitive, .regularExpression])
                if range != nil {
                    let attributedText = NSMutableAttributedString.init(string: number!, attributes: attrs)
                    attributedText.setAttributes(subAttrs, range: range!.nsRange)
                    
                    label!.attributedText = attributedText
                    
                    return
                }
            }
            
            label!.text = number
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cella1", for: indexPath) as! ContactTableViewCell
        
        //ricavo un oggetto Alimento dalla lista in posizione row (il num di riga) e lo conservo
        let item = self.dataSource[indexPath.row] as! [String: String]
        
        let imageData = ContactsUtils.shared().getImageFromContact(idetifier: item["identifier"]!)
        cell.avatarImageView?.image = imageData != nil ? UIImage.init(data: imageData!) : UIImage.init(named: "avatar")
        
        self.restyleNameLabel(label: cell.nameLabel, givenName: item["givenName"], familyName: item["familyName"], fullName: item["fullName"])
        self.restyleNumberLabel(label: cell.numberLabel, number: item["numberFormat"])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let item = self.dataSource[indexPath.row] as! [String: String]
        self.currentSelection = item
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let number = self.currentSelection["number"] ?? ""
        self.makeCall(formatedNumber: number)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    // MARK: - scrollView delegate
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        
        if translation.y > 0 {
            
        } else {
            
            self.searchBar.resignFirstResponder()
            
        }
    }
    
}

