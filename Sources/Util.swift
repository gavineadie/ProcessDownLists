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
    func padTo12(_ pad: String = " ") -> String { self.padding(toLength: 12, withPad: pad, startingAt: 0) }
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

    "CMPG22DL" : "Program 22 (CM-77773)",
    "CMPOWEDL" : "Powered (CM-77774)",
    "CMRENDDL" : "Rendezvous and Prethrust (CM-77775)",
    "CMENTRDL" : "Entry and Update (CM-77776)",
    "CMCSTADL" : "Coast and Align (CM-77777)",

    "LMLSALDL" : "Surface Align (LM-77772)",
    "LMDSASDL" : "Descent and Ascent (LM-77773)",
    "LMORBMDL" : "Orbital Maneuvers (LM-77774)",
    "LMRENDDL" : "Rendezvous/Prethrust (LM-77775)",
    "LMAGSIDL" : "AGS Initialization and Update (LM-77776)",
    "LMCSTADL" : "Coast and Align (LM-77777)",

    // Zerlina onwards

    "SURFALIN" : "Surface Align (LM-77772)",
    "DESC/ASC" : "Descent and Ascent (LM-77773)",
    "ORBMANUV" : "Orbital Maneuvers (LM-77774)",
    "RENDEZVU" : "Rendezvous/Prethrust (LM-77775)",
    "AGSI/UPD" : "AGS Initialization and Update (LM-77776)",
    "COSTALIN" : "Coast and Align (LM-77777)",

]
