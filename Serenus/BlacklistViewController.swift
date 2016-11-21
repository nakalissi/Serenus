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
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(appliationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
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
        mutateItems { (items: inout [String]) in
            items.append(keyword)
        }
        
        tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mutateItems { (items: inout [String]) in
                items.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        mutateItems { (items: inout [String]) in
            let item = items.remove(at: sourceIndexPath.row)
            items.insert(item, at: destinationIndexPath.row)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func didTapEdit() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    func appliationWillEnterForeground() {
        tableView.reloadData()
    }
    
    // MARK: - Private
    
    private func mutateItems(action: (inout [String]) -> Void) {
        var items = userDefaults?.stringArray(forKey: "BlacklistKeywords") ?? []
        action(&items)
        userDefaults?.set(items, forKey: "BlacklistKeywords")
        
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.noisysocks.Serenus.ContentBlocker", completionHandler: {
            (error: Error?) -> Void in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        })
    }
}
