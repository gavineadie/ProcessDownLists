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

    "CMPG22DL" : "Command Module Program 22 (CM-77773)",
    "CMPOWEDL" : "Command Module Powered (CM-77774)",
    "CMRENDDL" : "Command Module Rendezvous and Prethrust (CM-77775)",
    "CMENTRDL" : "Command Module Entry and Update (CM-77776)",
    "CMCSTADL" : "Command Module Coast and Align (CM-77777)",

    "LMLSALDL" : "Lunar Module Surface Align (LM-77772)",
    "LMDSASDL" : "Lunar Module Descent and Ascent (LM-77773)",
    "LMORBMDL" : "Lunar Module Orbital Maneuvers (LM-77774)",
    "LMRENDDL" : "Lunar Module Rendezvous/Prethrust (LM-77775)",
    "LMAGSIDL" : "Lunar Module AGS Initialization and Update (LM-77776)",
    "LMCSTADL" : "Lunar Module Coast and Align (LM-77777)",

    // Zerlina onwards

    "SURFALIN" : "Lunar Module Surface Align (LM-77772)",
    "DESC/ASC" : "Lunar Module Descent and Ascent (LM-77773)",
    "ORBMANUV" : "Lunar Module Orbital Maneuvers (LM-77774)",
    "RENDEZVU" : "Lunar Module Rendezvous/Prethrust (LM-77775)",
    "AGSI/UPD" : "Lunar Module AGS Initialization and Update (LM-77776)",
    "COSTALIN" : "Lunar Module Coast and Align (LM-77777)",

]
