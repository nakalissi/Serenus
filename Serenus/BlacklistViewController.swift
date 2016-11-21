//
//  BlacklistViewController.swift
//  Serenus
//
//  Created by Robert Anderson on 11/20/16.
//  Copyright © 2016 Robert Anderson. All rights reserved.
//

import UIKit
import SafariServices

final class BlacklistViewController: UITableViewController, AddKeywordViewControllerDelegate {

    private let userDefaults = UserDefaults(suiteName: "group.com.noisysocks.Serenus")
    
    // MARK: - UIViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddKeyword" {
            if let navigationController = segue.destination as? UINavigationController,
                let destination = navigationController.topViewController as? AddKeywordViewController {
                destination.delegate = self
            }
            else {
                fatalError("That ain't where this segue is supposed to go!")
            }
        }
    }
    
    // MARK: - AddKeywordViewControllerDelegate
    
    func didSave(keyword: String) {
        var items = userDefaults?.stringArray(forKey: "BlacklistKeywords") ?? []
        items.append(keyword)
        userDefaults?.set(items, forKey: "BlacklistKeywords")
        
        tableView.reloadData()
        
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.noisysocks.Serenus.ContentBlocker", completionHandler: {
            (error: Error?) -> Void in
            print("did stuff")
            if let error = error {
                print(error)
            }
        })
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDefaults?.stringArray(forKey: "BlacklistKeywords")?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Keyword", for: indexPath)
        
        if let items = userDefaults?.stringArray(forKey: "BlacklistKeywords") {
             cell.textLabel?.text = items[indexPath.row]
        }
        
        return cell
    }
}
