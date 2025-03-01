//
//  main.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/6/25.
//

import Foundation
import Logging

let fileManager = FileManager.default
let logger = Logger(label: "com.ramsaycons.PDL")

let homeDirURL = fileManager.homeDirectoryForCurrentUser
let workDirURL = homeDirURL.appendingPathComponent("Developer/virtualagc",
                                                   isDirectory: true)

let resourceKeys: [URLResourceKey] = [.nameKey, .isDirectoryKey]

var fileURLs: [URL] = []

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ make a list of all the "DOWNLINK_LISTS.agc" files ..                                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
if let enumerator = fileManager.enumerator(at: workDirURL,
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
var equalities: [String : String] = [:]              // LABEL : LABEL

let originalStdout = dup(STDOUT_FILENO)

do {
    for fileURL in fileURLs {

        let fileName = fileURL.deletingLastPathComponent().lastPathComponent
        let fileText = try String(contentsOf: fileURL, encoding: .utf8)
        let homeDirURL = fileManager.homeDirectoryForCurrentUser

/*────────────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesT: [String] = []

        let tidyPrintURL = homeDirURL.appendingPathComponent("Desktop/downlist/\(fileName)-tidy.txt")
        fileManager.createFile(atPath: tidyPrintURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: tidyPrintURL) {
            defer { fileHandle.closeFile() }
            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

            fileLinesT = tidyFile(fileName, fileText)        // tidy this file ..
            fileLinesT.forEach { print("\($0)") }
        }

        dup2(originalStdout, STDOUT_FILENO)

        print("tidyFile: Processed \(fileName).")

/*────────────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesM: [String] = []

        let mashPrintURL = homeDirURL.appendingPathComponent("Desktop/downlist/\(fileName)-mash.txt")
        fileManager.createFile(atPath: mashPrintURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: mashPrintURL) {
            defer { fileHandle.closeFile() }
            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

            fileLinesM = mashFile(fileName, fileLinesT)
//          fileLinesM.forEach { print("\($0)") }
        }

        dup2(originalStdout, STDOUT_FILENO)

        print("mashFile: Processed \(fileName).")

/*────────────────────────────────────────────────────────────────────────────────────────────────────*/
//        let listPrintURL = homeDirURL.appendingPathComponent("Desktop/downlist/\(fileName)-list.txt")
//        fileManager.createFile(atPath: listPrintURL.path, contents: nil, attributes: nil)
//
//        if let fileHandle = try? FileHandle(forWritingTo: listPrintURL) {
//            defer { fileHandle.closeFile() }
//            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)
//
//            print(">>> DOWNLISTS")
//            prettyPrint(downlists)
//
//            print(">>> COPYLISTS")
//            prettyPrint(copylists)
//
//            print(">>> EQUALS")
//            print(equalites)
//        }
//
//        dup2(originalStdout, STDOUT_FILENO)
//
//        print("listFile: Processed \(fileName).")

/*────────────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesJ: [String] = []

        let joinPrintURL = homeDirURL.appendingPathComponent("Desktop/downlist/\(fileName)-join.txt")
        fileManager.createFile(atPath: joinPrintURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: joinPrintURL) {
            defer { fileHandle.closeFile() }
            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

            fileLinesJ = joinFile(fileName)                                  // ..
//          fileLinesJ.forEach { print("\($0)") }
        }

        dup2(originalStdout, STDOUT_FILENO)

        downlists = [:]
        copylists = [:]
        equalities = [:]

        print("joinFile: Processed \(fileName).")

/*────────────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesD: [String] = []

        let dataPrintURL = homeDirURL.appendingPathComponent("Desktop/downlist/\(fileName)-data.txt")
        fileManager.createFile(atPath: dataPrintURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: dataPrintURL) {
            defer { fileHandle.closeFile() }
            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

            fileLinesD = dataFile(fileName, fileLinesJ)                 // ..
            fileLinesD.forEach { print("\($0)") }
        }

        dup2(originalStdout, STDOUT_FILENO)

        print("dataFile: Processed \(fileName).")

    }

} catch {
    print("Error: \(error.localizedDescription)")
}




fileprivate func prettyPrint(_ downlists: [String: [String]]) {
    for (label, lines) in downlists.sorted(by: { $0.key < $1.key }) {
        print("")
        if lines.isNotEmpty {
            print("~".padTo36("~"))
            if lines.first?.first == " " {
                print("\(label.padTo10()) [DOWNLIST]")
            } else {
                print("\(label.padTo10()) \(lines.first!.contains("  -") ? "[SNAPSHOT]" : "[COPYLIST]")")
            }
            print("~".padTo36("~"))
            for line in lines {
                print("\(line)")
            }
            print("")
        } else {
            print("\(label.padTo10()) [MISSING]")
        }
    }
}
