//
//  Data.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/24/25.
//

import Foundation

func dataFile(_ fileName: String, _ fileLines: [String]) -> [String] {

    print("###  \((fileName.uppercased() + "  ").padding(toLength: 72, withPad: "=", startingAt: 0))")
    print("###     emit tabular data ..   ")
    print("###  \(("").padding(toLength: 72, withPad: "=", startingAt: 0))\n")

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ process the lines of the file to isolate downlists ..                                            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    var newLines: [String] = []

    for var line in fileLines {

        guard line.isNotEmpty else { continue }
        if line.starts(with: "# ") || line.starts(with: "#*") { continue }
        if line.starts(with: "##") { newLines.append(line); continue }

        line = line.replacingOccurrences(of: "SNAPSHOT", with: "")
        line = line.replacingOccurrences(of: "COMMON DATA", with: "")
        line = line.replacingOccurrences(of: "SNAPSHOT DATA", with: "")

        if line.contains("SPARE") { line.append("# SPARE") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     2DNADR CMDAPMOD                     #   (034,036) # CMDAPMOD,PREL,QREL,RREL                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let match = line.firstMatch(of: #/^\s+(\w+)\s+(.+)#(.+)#(.+)/#) {

            let _1 = String(match.1)
            var _2 = match.2.trimmingCharacters(in: .whitespaces)
            if _2 == "SPARE" { _2 = " " }
            let _3 = String(match.3)
            let _4 = match.4.trimmingCharacters(in: .whitespaces)

            if let downCount = Int(String(_1.first!)) {                 // nDNADR
                newLines.append(emitLine(_1, _2, _3, _4))
                if downCount > 1 {
                    for _ in 2...downCount {
                        newLines.append(emitLine(" ", _2, _3, _4))
                    }
                }
            } else {
                newLines.append(emitLine(_1, _2, _3, _4))               // DNCHAN
            }

        } else {
            newLines.append(line)
        }

    }

    return newLines
}

fileprivate func emitLine(_ a: String, _ b: String = "", _ c: String = "", _ d: String = "") -> String {
    "» \(a.padTo16()) : \(b.padTo16()) : \(c.padTo16()) : \(d)"
}
