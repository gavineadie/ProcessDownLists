//
//  main.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on Feb06/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

let fileManager = FileManager.default
let homeDirURL = fileManager.homeDirectoryForCurrentUser
let workDirURL = homeDirURL.appendingPathComponent("Developer/virtualagc",
                                                   isDirectory: true)

let resourceKeys: [URLResourceKey] = [.nameKey, .isDirectoryKey]

let missionList = [
    "Colossus249", "Manche45R2", "Artemis072", "Skylark048",
    "Sundance306ish", "LUM69R2", "Luminary099", "LM131R1", "Zerlina56",
    "Luminary163", "Luminary178", "Luminary210",
]

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
            
        if fileURL.lastPathComponent == "DOWNLINK_LISTS.agc" { fileURLs.append(fileURL) }
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
var equalities: [String : String] = [:]             // LABEL : LABEL

let originalStdout = dup(STDOUT_FILENO)

do {
    for fileURL in fileURLs {

        let missionName = fileURL.deletingLastPathComponent().lastPathComponent

        if !missionList.contains(missionName) { continue }

//      if missionName != "Zerlina56" { continue }
//      if missionName != "Artemis072" { continue }
//      if missionName != "Skylark048" { continue }
//      if missionName != "Sundance306ish" { continue }

        let fileText = try String(contentsOf: fileURL, encoding: .utf8)
        let homeDirURL = fileManager.homeDirectoryForCurrentUser

/*─ TIDY ─────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesT: [String] = []

        let tidyPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-tidy.txt")
        fileManager.createFile(atPath: tidyPrintURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: tidyPrintURL) {
            defer { fileHandle.closeFile() }
            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

            fileLinesT = tidyFile(missionName, fileText)            // tidy this file ..
            fileLinesT.forEach { print("\($0)") }
        }

        dup2(originalStdout, STDOUT_FILENO)

        print("tidyFile: Processed \(missionName).")

/*─ MASH ─────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesM: [String] = []

        let mashPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-mash.txt")
        fileManager.createFile(atPath: mashPrintURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: mashPrintURL) {
            defer { fileHandle.closeFile() }
            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

            fileLinesM = mashFile(missionName, fileLinesT)
            fileLinesM.forEach { print("\($0)") }
        }

        dup2(originalStdout, STDOUT_FILENO)

        print("mashFile: Processed \(missionName).")

/*─ LIST ─────────────────────────────────────────────────────────────────────────────────────────────*/
        let listPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-list.txt")
        fileManager.createFile(atPath: listPrintURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: listPrintURL) {
            defer { fileHandle.closeFile() }
            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

            print(">>> DOWNLISTS")
            prettyPrint(downlists)

            print(">>> COPYLISTS")
            prettyPrint(copylists)

            print(">>> EQUALS")
            print(equalities)
        }

        dup2(originalStdout, STDOUT_FILENO)

        print("listFile: Processed \(missionName).")

/*─ JOIN ─────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesJ: [String] = []

        let joinPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-join.txt")
        fileManager.createFile(atPath: joinPrintURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: joinPrintURL) {
            defer { fileHandle.closeFile() }
            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

            fileLinesJ = joinFile(missionName)                      // ..
            fileLinesJ.forEach { print("\($0)") }
        }

        dup2(originalStdout, STDOUT_FILENO)

        downlists = [:]
        copylists = [:]
        equalities = [:]

        print("joinFile: Processed \(missionName).")

/*─ DATA ─────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesD: [String] = []

        let dataPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-data.txt")
        fileManager.createFile(atPath: dataPrintURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: dataPrintURL) {
            defer { fileHandle.closeFile() }
            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

            fileLinesD = dataFile(missionName, fileLinesJ)          // ..
            fileLinesD.forEach { print("\($0)") }
        }

        dup2(originalStdout, STDOUT_FILENO)

        print("dataFile: Processed \(missionName).")

/*─ XTRA ─────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesX: [String] = []

        let xtraPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-xtra.tsv")
        fileManager.createFile(atPath: xtraPrintURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: xtraPrintURL) {
            defer { fileHandle.closeFile() }
            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

            fileLinesX = xtraFile(missionName, fileLinesD)          // ..
            fileLinesX.forEach { print("\($0)") }
        }

        dup2(originalStdout, STDOUT_FILENO)

        print("xtraFile: Processed \(missionName).")

/*─ SORT ─────────────────────────────────────────────────────────────────────────────────────────────*/
        sortFile(missionName, fileLinesX)                           // ..

        print("sortFile: Processed \(missionName).")                // writes TSV files

/*─ TELE ─────────────────────────────────────────────────────────────────────────────────────────────*/
        teleFile(missionName, fileLinesX)                           // ..

        print("teleFile: Processed \(missionName).")                // writes Swift files

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
