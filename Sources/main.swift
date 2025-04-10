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

extractOptions()

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

let allFileURLs = try! fileManager.contentsOfDirectory(at: workDirURL,
                                                 includingPropertiesForKeys: [],
                                                 options: .skipsHiddenFiles)

for fileURL in allFileURLs {
    if fileURL.hasDirectoryPath {
        let allFileURLs = try! fileManager.contentsOfDirectory(at: fileURL,
                                             includingPropertiesForKeys: [],
                                             options: .skipsHiddenFiles)
        for fileURL in allFileURLs {
            if fileURL.lastPathComponent == "DOWNLINK_LISTS.agc" {
                fileURLs.append(fileURL)
                print(fileURL)
            }
        }
    }
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

        guard missionList.contains(missionName) else { continue }

//      if missionName != "Zerlina56" { continue }
//      if missionName != "Artemis072" { continue }
//      if missionName != "Skylark048" { continue }
//      if missionName != "Sundance306ish" { continue }

        let fileText = try String(contentsOf: fileURL, encoding: .utf8)
        let homeDirURL = fileManager.homeDirectoryForCurrentUser

/*─ TIDY ─────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesT: [String] = []

        if emitDiagnosticFiles {
            let tidyPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-tidy.txt")
            _ = fileManager.createFile(atPath: tidyPrintURL.path, contents: nil, attributes: nil)

            if let fileHandle = try? FileHandle(forWritingTo: tidyPrintURL) {
                defer { fileHandle.closeFile() }
                dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

                fileLinesT = tidyFile(missionName, fileText)            // tidy this file ..
                fileLinesT.forEach { print("\($0)") }
            }

            dup2(originalStdout, STDOUT_FILENO)
        } else {
            fileLinesT = tidyFile(missionName, fileText)                // tidy this file ..
        }

        print("tidyFile: Processed \(missionName).")

/*─ MASH ─────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesM: [String] = []

        if emitDiagnosticFiles {
            let mashPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-mash.txt")
            _ = fileManager.createFile(atPath: mashPrintURL.path, contents: nil, attributes: nil)

            if let fileHandle = try? FileHandle(forWritingTo: mashPrintURL) {
                defer { fileHandle.closeFile() }
                dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

                fileLinesM = mashFile(missionName, fileLinesT)
                fileLinesM.forEach { print("\($0)") }
            }

            dup2(originalStdout, STDOUT_FILENO)
        } else {
            fileLinesM = mashFile(missionName, fileLinesT)
        }

        print("mashFile: Processed \(missionName).")

/*─ LIST ─────────────────────────────────────────────────────────────────────────────────────────────*/
        if emitDiagnosticFiles {
            let listPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-list.txt")
            _ = fileManager.createFile(atPath: listPrintURL.path, contents: nil, attributes: nil)

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
        }

        print("listFile: Processed \(missionName).")

/*─ JOIN ─────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesJ: [String] = []

        if emitDiagnosticFiles {
            let joinPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-join.txt")
            _ = fileManager.createFile(atPath: joinPrintURL.path, contents: nil, attributes: nil)

            if let fileHandle = try? FileHandle(forWritingTo: joinPrintURL) {
                defer { fileHandle.closeFile() }
                dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

                fileLinesJ = joinFile(missionName)                      // ..
                fileLinesJ.forEach { print("\($0)") }
            }

            dup2(originalStdout, STDOUT_FILENO)
        } else {
            fileLinesJ = joinFile(missionName)                          // ..
        }

        downlists = [:]
        copylists = [:]
        equalities = [:]

        print("joinFile: Processed \(missionName).")

/*─ DATA ─────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesD: [String] = []

        if emitDiagnosticFiles {
            let dataPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-data.txt")
            _ = fileManager.createFile(atPath: dataPrintURL.path, contents: nil, attributes: nil)

            if let fileHandle = try? FileHandle(forWritingTo: dataPrintURL) {
                defer { fileHandle.closeFile() }
                dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

                fileLinesD = dataFile(missionName, fileLinesJ)          // ..
                fileLinesD.forEach { print("\($0)") }
            }

            dup2(originalStdout, STDOUT_FILENO)
        } else {
            fileLinesD = dataFile(missionName, fileLinesJ)              // ..
        }

        print("dataFile: Processed \(missionName).")

/*─ XTRA ─────────────────────────────────────────────────────────────────────────────────────────────*/
        var fileLinesX: [String] = []

        if emitDiagnosticFiles {
            let xtraPrintURL = homeDirURL.appendingPathComponent("Desktop/Downlist/\(missionName)-stab.txt")
            _ = fileManager.createFile(atPath: xtraPrintURL.path, contents: nil, attributes: nil)

            if let fileHandle = try? FileHandle(forWritingTo: xtraPrintURL) {
                defer { fileHandle.closeFile() }
                dup2(fileHandle.fileDescriptor, STDOUT_FILENO)

                fileLinesX = xtraFile(missionName, fileLinesD)          // ..
                fileLinesX.forEach { print("\($0)") }
            }

            dup2(originalStdout, STDOUT_FILENO)
        } else {
            fileLinesX = xtraFile(missionName, fileLinesD)              // ..
        }

        print("xtraFile: Processed \(missionName).")

/*─ SORT ─────────────────────────────────────────────────────────────────────────────────────────────*/
//        sortFile(missionName, fileLinesX)                           // ..
//
//        print("sortFile: Processed \(missionName).")                // writes TSV files

/*─ TELE ─────────────────────────────────────────────────────────────────────────────────────────────*/
//#if os(macOS)
//        teleFile(missionName, fileLinesX)                           // ..
//
//        print("teleFile: Processed \(missionName).")                // writes Swift files
//#endif

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

var emitDiagnosticFiles = false
var importDirectory = ""
var exportDirectory = ""

fileprivate func extractOptions() {
    let args = CommandLine.arguments

    for var arg in args {
        logger.info("command line argument: \(arg)")

        if arg.hasPrefix("--diagnostics") || arg.hasPrefix("-d") { emitDiagnosticFiles = true }

        else if arg.hasPrefix("--import=") { arg.removeFirst(9); importDirectory = arg }

        else if arg.hasPrefix("--export=") { arg.removeFirst(9); exportDirectory = arg }
    }
}
