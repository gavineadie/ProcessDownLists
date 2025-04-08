//
//  Xtra.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on Mar05/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation
import RegexBuilder

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ .. reads from "*.join.txt" file and writes to "*.xtra.tsv"                                       │
  │╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌│
  │╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌│
  │                                                                                                  │
  │ .. append extra columns ..                                                                       │
  │                                                                                                  │
  │     0   ID          : B0     FMT_OCT                                                             │
  │     1   SYNC        : B0     FMT_OCT                                                             │
  │     2   R-OTHER+0   : B29    FMT_DP                                                              │
  │     4   R-OTHER+2   : B29    FMT_DP                                                              │
  │     6   R-OTHER+4   : B29    FMT_DP                                                              │
  │     8   V-OTHER+0   : B7     FMT_DP                                                              │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

func xtraFile(_ missionName: String, _ fileLines: [String]) -> [String] {
    var newLines: [String] = []

    for line in fileLines {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ keep lines with no tabs ..                                                                       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var columns = line.split(separator: "\t")

        if columns.count == 1 { newLines.append(line); continue }

        guard columns.count == 3 else { fatalError("column count not 3 in \(line)") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ corrections ..                                                                                   ┆
  ┆     style:  remove "+0" on variables                                                             ┆
  ┆             mark where there's unused cells                                                      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        columns[1].replace("+0", with: "")

        if ["SPARE", "GARBAGE"].contains(columns[1]) {
            let newLine = "# offset \(columns[0].trimmingCharacters(in: .whitespacesAndNewlines)) is unused"
            newLines.append(newLine)
            continue
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ GSOP substitutes .. we don't do this any more                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
//      let gsopName = lookupGsopNames[columns[1]] ?? columns[1]
//      let tabLine = "\(columns[0])\t\(gsopName): \(getLookup(columns[1]))"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ clean up for tab-separated-value output ..                                                       ┆
  ┆     edit: "«whitespace»:«whitespace»" to one tab                                                 ┆
  ┆     edit: "«tab»tFormatRequired«tab»" to two tabs                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let tabLine = "\(columns[0])\t\(columns[1]): \(getLookup(columns[1]))"
            .replacing(Regex {
                ZeroOrMore(.whitespace)
                ":"
                ZeroOrMore(.whitespace)
            }, with: "\t")
            .replacing("\tFormatRequired\t", with: "\t\t")

        newLines.append(tabLine)
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ do a sanity check for offset errors .. that is offset should increment by                        │
  │     1 for FMT_OCT, FMT_DEC, FMT_SP, FMT_USP                                                      │
  │     2 for FMT_2OCT, FMT_2DEC, FMT_DP ..                                                          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    let testLines = newLines
        .filter { !$0.starts(with: "##") }
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

    for i in 0..<testLines.count-1 {

        let columnsThis = testLines[i].split(separator: "\t")
        let columnsNext = testLines[i+1].split(separator: "\t")

        if columnsThis.count == 1 || columnsNext.count == 1 { continue } 
        if columnsThis[0].starts(with: "#") { continue }
        if columnsNext[0].starts(with: "#") { continue }
        if Int(columnsNext[0])! == 0 { continue }

        if ["FMT_OCT", "FMT_DEC", "FMT_SP", "FMT_USP"].contains(columnsThis[3]) {
            if columnsNext[0].starts(with: "#") { continue }
            if Int(columnsNext[0])! - Int(columnsThis[0])! == 1 {continue }
        }

        if ["FMT_2OCT", "FMT_2DEC", "FMT_DP"].contains(columnsThis[3]) {
            if Int(columnsNext[0])! - Int(columnsThis[0])! == 2 { continue }
        }

        logger.info("""
            line \(i) of file \(missionName).tsv:
               \(testLines[i])
               \(testLines[i+1])
            """)

    }

    return newLines
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ try an exact match, then a match after removing "+n", and then a initial substring match ..      │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
fileprivate func getLookup(_ key: Substring) -> String {
    for (k, v) in lookupScaleFormatUnits { if key == k { return v } }
    for (k, v) in lookupScaleFormatUnits { if key.replacing(#/\+\d+/#, with: "") == k { return v } }
    for (k, v) in lookupScaleFormatUnits { if key.starts(with: k) { return v } }
    return "B0   : FMT_OCT  : FormatUnknown       : TBD"
}
