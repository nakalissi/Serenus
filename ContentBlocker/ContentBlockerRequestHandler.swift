//
//  ContentBlockerRequestHandler.swift
//  ContentBlocker
//
//  Created by Robert Anderson on 11/20/16.
//  Copyright © 2016 Robert Anderson. All rights reserved.
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {
    
    private let userDefaults = UserDefaults(suiteName: "group.com.noisysocks.Serenus")

    func beginRequest(with context: NSExtensionContext) {
        let blacklistKeywords = userDefaults?.stringArray(forKey: "BlacklistKeywords") ?? []
        let blockerList = blacklistKeywords.map {
            (keyword: String) -> [String: Any] in
            let escapedKeyword = NSRegularExpression.escapedPattern(for: keyword)
            return [
                "action": ["type": "block"],
                "trigger": ["url-filter": "https?://.*\(escapedKeyword).*/.*"],
            ]
        }
        
        let fileName = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "blockerList.json")
        guard let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName) else {
            NSLog("Error while creating temporary file URL")
            return
        }
        
        guard let stream = OutputStream(url: fileURL, append: false) else {
            NSLog("Error while opening temporary file stream")
            return
        }
        
        stream.open()
        var error: NSError?
        JSONSerialization.writeJSONObject(blockerList, to: stream, options: .prettyPrinted, error: &error)
        stream.close()
        guard error == nil else {
            NSLog("Error while writing JSON to temporary file")
            return
        }
        
        guard let attachment = NSItemProvider(contentsOf: fileURL) else {
            NSLog("Error while loading attachment")
            return
        }
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
}
