//
//  main.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/6/25.
//

import Foundation
import RegexBuilder

let fileManager = FileManager.default
let directoryURL = URL(fileURLWithPath: "/Users/gavin/Developer/virtualagc")
let resourceKeys: [URLResourceKey] = [.nameKey, .isDirectoryKey]

var fileURLs: [URL] = []

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ make a list of all the "DOWNLINK_LISTS.agc" files ..                                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
if let enumerator = fileManager.enumerator(at: directoryURL,
                                           includingPropertiesForKeys: resourceKeys,
                                           options: [.skipsHiddenFiles],
                                           errorHandler: { (url, error) -> Bool in
    print("Error accessing file: \(url): \(error)")
    return true                                                 // Continue enumeration
}) {
    for case let fileURL as URL in enumerator {
        if fileURL.absoluteString.contains("/VirtualAGC/") { continue }
            
        if fileURL.lastPathComponent == "DOWNLINK_LISTS.agc" {
            fileURLs.append(fileURL)
        }
    }
} else {
    print("Failed to create enumerator.")
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ process each file ..                                                                             │
  │     within each file there are 'downlists', 'copylists' and 'equates' to be gathered ..          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

var downlists: [String : [String]] = [:]            // LABEL : LINES
var copylists: [String : [String]] = [:]            // LABEL : LINES
var equalites: [String : String] = [:]              // LABEL : LABEL

do {
    for fileURL in fileURLs {

        let fileName = fileURL.deletingLastPathComponent().lastPathComponent
        let fileText = try String(contentsOf: fileURL, encoding: .utf8)

        let fileLines = tidyFile(fileName, fileText)        // tidy this file ..
        mashFile(fileName, fileLines)                       // ..

        joinFile(fileName)                                  // ..

        downlists = [:]
        copylists = [:]
        equalites = [:]

    }

    print("\(#function): Processing complete.")

} catch {
    print("Error: \(error.localizedDescription)")
}

