//
//  Xtra.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 3/5/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation
import RegexBuilder

func xtraFile(_ missionName: String, _ fileLines: [String]) -> [String] {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ process the lines of the file and append extra columns ..                                        ┆
  ┆                                                                                                  ┆
  ┆     0   ID          : B0     FMT_OCT                                                             ┆
  ┆     1   SYNC        : B0     FMT_OCT                                                             ┆
  ┆     2   R-OTHER+0   : B29    FMT_DP                                                              ┆
  ┆     4   R-OTHER+2   : B29    FMT_DP                                                              ┆
  ┆     6   R-OTHER+4   : B29    FMT_DP                                                              ┆
  ┆     8   V-OTHER+0   : B7     FMT_DP                                                              ┆
  ┆     10  V-OTHER+2   : B7     FMT_DP                                                              ┆
  ┆     12  V-OTHER+4   : B7     FMT_DP                                                              ┆
  ┆     14  T-OTHER+0   : B28    FMT_DP                                                              ┆
  ┆     16  DNRRANGE    : B28    FMT_DP                                                              ┆
  ┆     17  DNRRDOT     : B28    FMT_DP                                                              ┆
  ┆                                                                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    var newLines: [String] = []

    for line in fileLines {

        if line.starts(with: "##") { newLines.append(line); order = 0; continue }

        var columns = line.split(separator: "\t")
        guard columns.count == 3 else { fatalError("too many columns in \(line)") }

        if columns[0] == "2" || columns[0] == "\n2" {
            newLines.append("100\tTIME\tB28\tFMT_DP\t\tTBD")
        }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ corrections ..                                                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        columns[1].replace("+0", with: "")

        if ["SPARE", "GARBAGE"].contains(columns[1]) {
            let newLine = "# offset \(columns[0]) is unused"
            newLines.append(newLine)
            continue
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ GSOP substitutes ..                                                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
//      let gsopName = lookupGsopNames[columns[1]] ?? columns[1]
//      let tabLine = "\(columns[0])\t\(gsopName): \(getLookup(columns[1]))"


//      let txtLine = "\(columns[0])\t\(columns[1].padTo12()): \(getLookup(columns[1]))"
        let tabLine = "\(columns[0])\t\(columns[1]): \(getLookup(columns[1]))"
            .replacing(Regex {
                ZeroOrMore(.whitespace)
                ":"
                ZeroOrMore(.whitespace)
            }, with: "\t")
            .replacing("\tFormatRequired\t", with: "\t\t")

        //        newLines.append(newLine)
        newLines.append(tabLine)
    }

    return newLines
}

fileprivate func getLookup(_ key: Substring) -> String {

    for (k, v) in lookupScaleFormatUnits {
        if key == k { return v }
    }

    for (k, v) in lookupScaleFormatUnits {
        if key.starts(with: k) { return v }
    }

    return "B0   : FMT_OCT  : FormatUnknown       : TBD"
}
