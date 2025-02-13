//
//  Util.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/9/25.
//

import Foundation

extension Collection {
    var isNotEmpty: Bool { !self.isEmpty }
}

extension StringProtocol {
    func padTo10(_ pad: String = " ") -> String { self.padding(toLength: 10, withPad: pad, startingAt: 0) }
    func padTo16(_ pad: String = " ") -> String { self.padding(toLength: 16, withPad: pad, startingAt: 0) }
    func padTo36(_ pad: String = " ") -> String { self.padding(toLength: 36, withPad: pad, startingAt: 0) }
    func padTo72(_ pad: String = " ") -> String { self.padding(toLength: 72, withPad: pad, startingAt: 0) }
}

//let pattern = Regex {
//    ChoiceOf {
//        Regex {
//            /^/
//            Capture { ZeroOrMore(.whitespace.inverted) }
//            ZeroOrMore(.whitespace)
//            Capture { ZeroOrMore(.reluctant) { /./ } }
//            ZeroOrMore(.whitespace)
//            Capture {
//                Regex {
//                    "#"
//                    ZeroOrMore { /./ }
//                }
//            }
//        }
//        
//        Regex {
//            /^/
//            Capture { ZeroOrMore(.whitespace.inverted) }
//            ZeroOrMore(.whitespace)
//            Capture { ZeroOrMore { /./ } }
//        }
//    }
//}

//struct DownList {
//    var title: String
//    var line2: String
//    var label: String
//    var lines: [String]
//    
//    init() {
//        self.title = ""
//        self.line2 = ""
//        self.label = ""
//        self.lines = [String]()
//    }
//    
//    mutating  func dump() {
//        if label.isEmpty { return }
//
//        if title.isEmpty { title = label }
//
//        let printURL = URL(fileURLWithPath: "/Users/gavin/Desktop/downlist/\(title)-dump.txt")
//        fileManager.createFile(atPath: printURL.path, contents: nil, attributes: nil)
//
//        let originalStdout = dup(STDOUT_FILENO)
//
//        if let fileHandle = try? FileHandle(forWritingTo: printURL) {
//            defer { fileHandle.closeFile() }
//            dup2(fileHandle.fileDescriptor, STDOUT_FILENO)
//        }
//
//        print(" • # \(title.uppercased())")
//        print(" • \(line2)")
////        print(" •")
//        if title.isEmpty {
//            print(" • \(label.padTo10())ID")
//            print(" • \("".padTo10())SYNC")
//        }
//        lines.forEach { print(" • \($0)") }
//
//        dup2(originalStdout, STDOUT_FILENO)
//        close(originalStdout)
//    }
//
//    mutating func zero() {
//        title = ""
//        line2 = ""
//        label = ""
//        lines = [String]()
//    }
//
//    func process() {
//        if label.isEmpty { return }
//
//        print(" → # \(title.uppercased())")
//        print(" → \(line2)\n •")
//
//    }
//}

func doMatch(_ line: String) -> (String, String, String) {
    let pattern = #/^(\S*)\s*(.*?)\s*(#.*)|^(\S*)\s*(.*)/#

    guard let match = line.wholeMatch(of: pattern) else { return ("", "", "") }

    let label = String(match.1 ?? match.4 ?? "")
    let opcode = (match.2 ?? match.5 ?? "")
        .trimmingCharacters(in: .whitespaces)
        .replacing(#/\s+/#, with: " ", maxReplacements: 2)
    let comment = String(match.3 ?? "")

    return (label, opcode, comment)
}

let downListIDs = [

    "LMLSALDL" : "Lunar Module Surface Align (LM-77772)",
    "LMDSASDL" : "Lunar Module Descent and Ascent (LM-77773)",
    "LMORBMDL" : "Lunar Module Orbital Maneuvers (LM-77774)",
    "LMRENDDL" : "Lunar Module Rendezvous/Prethrust (LM-77775)",
    "LMAGSIDL" : "Lunar Module AGS Initialization and Update (LM-77776)",
    "LMCSTADL" : "Lunar Module Coast and Align (LM-77777)",

    "CMPG22DL" : "Command Module Program 22 (CM-77773)",
    "CMPOWEDL" : "Command Module Powered (CM-77774)",
    "CMRENDDL" : "Command Module Rendezvous and Prethrust (CM-77775)",
    "CMENTRDL" : "Command Module Entry and Update (CM-77776)",
    "CMCSTADL" : "Command Module Coast and Align (CM-77777)",

    // Zerlina

    "SURFALIN" : "Lunar Module Surface Align (LM-77772)",
    "DESC/ASC" : "Lunar Module Descent and Ascent (LM-77773)",
    "ORBMANUV" : "Lunar Module Orbital Maneuvers (LM-77774)",
    "RENDEZVU" : "Lunar Module Rendezvous/Prethrust (LM-77775)",
    "AGSI/UPD" : "Lunar Module AGS Initialization and Update (LM-77776)",
    "COSTALIN" : "Lunar Module Coast and Align (LM-77777)",

]
