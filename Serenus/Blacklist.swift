//
//  Blacklist.swift
//  Serenus
//
//  Created by Robert Anderson on 1/28/17.
//  Copyright © 2017 Robert Anderson. All rights reserved.
//

import Foundation
import SafariServices

struct Blacklist {
    
    private static let KeywordsKey = "BlacklistKeywords"
    
    private let userDefaults = UserDefaults(suiteName: "group.com.noisysocks.Serenus")
    
    var count: Int {
        return userDefaults?.stringArray(forKey: Blacklist.KeywordsKey)?.count ?? 0
    }
    
    var keywords: [String] {
        return userDefaults?.stringArray(forKey: Blacklist.KeywordsKey) ?? []
    }
    
    func keyword(at index: Int) -> String? {
        if let keywords = userDefaults?.stringArray(forKey: Blacklist.KeywordsKey) {
            return keywords[index]
        }
        else {
            return nil
        }
    }
    
    func mutate(action: (inout [String]) -> Void) {
        if var items = userDefaults?.stringArray(forKey: Blacklist.KeywordsKey) {
            action(&items)
            userDefaults?.set(items, forKey: Blacklist.KeywordsKey)
            
            SFContentBlockerManager.reloadContentBlocker(
                withIdentifier: "com.noisysocks.Serenus.ContentBlocker",
                completionHandler: { error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
            })
        }
    }
}
