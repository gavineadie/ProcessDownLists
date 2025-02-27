//
//  Data.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/24/25.
//

import Foundation
import RegexBuilder

func dataFile(_ fileName: String, _ fileLines: [String]) -> [String] {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ process the lines of the file to isolate downlists ..                                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    var newLines: [String] = []
    var index = 0

    for var line in fileLines {

        guard line.isNotEmpty else { continue }
        if line.starts(with: "# ") || line.starts(with: "#*") { continue }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ new downlink ..                                                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.starts(with: "##") { newLines.append(line); index = 0; continue }

        line.replace("SNAPSHOT", with: "")
        line.replace("COMMON DATA", with: "")
        line.replace("SNAPSHOT DATA", with: "")

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASE: these usages can be eliminated early ..                                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        line.replace("TIME/1", with: "TIME2,+1")
        line.replace("TIME2/1", with: "TIME2,+1")

        line.replace("DISPLAY TABLES", with: "DSPTAB +0...+11")
        line.replace("DSPTAB TABLES", with: "DSPTAB +0...+11")

        if line.contains("SPARE") { line.append("# SPARE") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ match an assembler line and split it into pieces:                                                ┆
  ┆                                                                                                  ┆
  ┆ "       2DNADR  CMDAPMOD                     #   (034,036) # CMDAPMOD,PREL,QREL,RREL"            ┆
  ┆         -----+  -------+                      ------------+  +----------------------             ┆
  ┆              |         |                                  |  |                                   ┆
  ┆              |         label: "CMDAPMOD"                  |  comment: "CMDAPMOD,PREL,QREL,RREL"  ┆
  ┆              |                                            |                                      ┆
  ┆              opCode: "2DNADR"                             range: "   (034,036) "                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let match = line.firstMatch(of: long) {

            var opCode = String(match.1)
            var label = match.2.trimmingCharacters(in: .whitespaces)
            if label == "SPARE" { label = " " }
            let range = String(match.3)
            let comment = match.4
                .replacingOccurrences(of: "DATA", with: "")                     // ← SPECIAL CASE
                .trimmingCharacters(in: .whitespaces)

            let commentBits = splitComment(label, comment)

            if opCode == "DNCHAN" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ DNCHAN .. channel downlink ..                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                newLines.append(emitLine(index, opCode, "CHAN"+label, range, "single", comment))
                index += 1
                newLines.append(emitLine(index, "      ", "CHAN"+commentBits[1], range, "single", comment))
                index += 1

                continue
            }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     process nDNADR (n words in downlist)                                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let downCount = Int(String(opCode.first!))!

            if downCount == commentBits.count/2 {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ SINGLE                                                                                           ┆
  ┆                        1DNADR DNLRVELZ                     # DNLRVELZ,DNLRALT                    ┆
  ┆                                                                                                  ┆
  ┆                 054  :  DNLRVELZ   :  single                                                     ┆
  ┆                 055  :  DNLRALT    :  single                                                     ┆
  ┆╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┆
  ┆                        2DNADR DNLRVELX                     # DNLRVELX,DNLRVELY,DNLRVELZ,DNLRALT  ┆
  ┆                                                                                                  ┆
  ┆                 048  :  DNLRVELX   :  single                                                     ┆
  ┆                 049  :  DNLRVELY   :  single                                                     ┆
  ┆                 050  :  DNLRVELZ   :  single                                                     ┆
  ┆                 051  :  DNLRALT    :  single                                                     ┆
  ┆╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┆
  ┆                        3DNADR AGSBUFF +0                   # AGSBUFF +0...+5                     ┆
  ┆                                                                                                  ┆
  ┆                 002  :  AGSBUFF+0  :  single                                                     ┆
  ┆                 003  :  AGSBUFF+1  :  single                                                     ┆
  ┆                 004  :  AGSBUFF+2  :  single                                                     ┆
  ┆                 005  :  AGSBUFF+3  :  single                                                     ┆
  ┆                 006  :  AGSBUFF+4  :  single                                                     ┆
  ┆                 007  :  AGSBUFF+5  :  single                                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                for bit in commentBits {
                    newLines.append(emitLine(index, opCode,
                                             String(bit), range,
                                             "single", comment))
                    opCode = "      "
                    index += 1
                }

                continue
            }

            if downCount == commentBits.count {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ DOUBLE                                                                                           ┆
  ┆                        1DNADR DNLRVELZ                     # DNLRVELZ,DNLRALT                    ┆
  ┆                                                                                                  ┆
  ┆                 054  :  DNLRVELZ   :  single                                                     ┆
  ┆                 055  :  DNLRALT    :  single                                                     ┆
  ┆╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┆
  ┆                        2DNADR DNLRVELX                     # DNLRVELX,DNLRVELY,DNLRVELZ,DNLRALT  ┆
  ┆                                                                                                  ┆
  ┆                 048  :  DNLRVELX   :  single                                                     ┆
  ┆                 049  :  DNLRVELY   :  single                                                     ┆
  ┆                 050  :  DNLRVELZ   :  single                                                     ┆
  ┆                 051  :  DNLRALT    :  single                                                     ┆
  ┆╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┆
  ┆                        3DNADR AGSBUFF +0                   # AGSBUFF +0...+5                     ┆
  ┆                                                                                                  ┆
  ┆                 002  :  AGSBUFF+0  :  single                                                     ┆
  ┆                 003  :  AGSBUFF+1  :  single                                                     ┆
  ┆                 004  :  AGSBUFF+2  :  single                                                     ┆
  ┆                 005  :  AGSBUFF+3  :  single                                                     ┆
  ┆                 006  :  AGSBUFF+4  :  single                                                     ┆
  ┆                 007  :  AGSBUFF+5  :  single                                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                for bit in commentBits {
                    newLines.append(emitLine(index, opCode,
                                             String(bit), range,
                                             "double", comment))
                    opCode = "      "
                    index += 2
                }

                continue
            }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ DOUBLE                                                                                           ┆
  ┆                                                                                                  ┆
  ┆ nDNADR : n = 1                                                                                   ┆
  ┆ ["A","B","C","D","E","F"]                                                                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            for i in 1...downCount {
                newLines.append(emitLine(index, i == 1 ? opCode : "      ",
                                         commentBits.count < downCount ? label : String(commentBits[i-1]),
                                         range, "double", comment))
                index += 2

                continue
            }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ failed to match the assembler line .. emit it anyway                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            newLines.append(line)
        }

    }

    return newLines
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ takes "R-OTHER" (label) and "R-OTHER +0,+1" (comment) and returns and array of new labels based  │
  │ on figuring out, as best as possible, offsets and single/douple precision ..                     │
  │                                                                                                  │
  │ .. if (label) == first substring of (comment)                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
fileprivate func splitComment(_ label: String, _ comment: String) -> [Substring] {
    var result = [Substring]()
    if comment.isEmpty { return result }

    if comment.contains("+") {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ comment text contains a "+"                                                                      ┆
  ┆                                                         split on "," and examine each sub-string ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var bits = comment.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        bits[0] = bits[0].replacingOccurrences(of: " ", with: "")

        if bits.count == 3 { if bits[1...2] == ["+1...+4", "+5"] { bits = [bits[0], "+1...+5"] } }
        if bits.count == 3 { if bits[1...2] == ["+1...+5", "+6"] { bits = [bits[0], "+1...+6"] } }
        if bits.count == 3 { if bits[1...2] == ["+1...+10", "+11"] { bits = [bits[0], "+1...+11"] } }
        if bits.count == 3 { if bits[1...2] == ["+1...+10", "+11D"] { bits = [bits[0], "+1...+11"] } }
        if bits.count == 3 { if bits[1...2] == ["+13...+18", "+19D"] { bits = [bits[0], "+13...+19"] } }
        if bits.count == 3 { if bits[1...2] == ["13...+18", "19D"] { bits = [bits[0], "+13...+19"] } }

        if bits.count == 4 { if bits[1...3] == ["+1", "...+4", "+5"] { bits = [bits[0], "+1...+5"] } }
        if bits.count == 4 { if bits[1...3] == ["+1", "+2", "...+5"] { bits = [bits[0], "+1...+5"] } }
        if bits.count == 4 { if bits[1...3] == ["+1", "...+10", "+11"] { bits = [bits[0], "+1...+11"] } }

        switch bits.count {
            case 1:
                if let match = bits[0].firstMatch(of: code) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["GSAV+0...+5"] → ["GSAV+0", "GSAV+1", "GSAV+2", "GSAV+3", "GSAV+4", "GSAV+5"]               ┆
  ┆     ["STAR+0...+5"] → ["STAR+0", "STAR+1", "STAR+2", "STAR+3", "STAR+4", "STAR+5"]               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let alpha = Int(String(match.2))!
                    let omega = Int(String(match.3))!
                    for i in alpha...omega { result.append("\(match.1)+\(i)") }
                    return result

                } else {
                    logger.log("×1 \(bits)")
                }

            case 2:
                if !bits[0].contains("+") && bits[1].contains("...") {
                    if bits[1] == "...+5" { bits[1] = "+1...+5" }               // ← SPECIAL CASE
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["DELV", "+1...+5"] → ["DELV+1", "DELV+2", "DELV+3", "DELV+4", "DELV+5"]                     ┆
  ┆     ["RLS", "+1...+5"] → ["RLS+1", "RLS+2", "RLS+3", "RLS+4", "RLS+5"]                           ┆
  ┆     ["VGTIG", "...+5"] → ["VGTIG+1", "VGTIG+2", "VGTIG+3", "VGTIG+4", "VGTIG+5"]                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    if let match = bits[1].firstMatch(of: dots) {
                        let alpha = Int(String(match.1))!
                        let omega = Int(String(match.2))!
                        for i in alpha...omega { result.append("\(bits[0])+\(i)") }
                        return result

                    } else {
                        logger.log("×2a \(bits)")
                    }

                } else if let matchA = bits[0].firstMatch(of: plus),
                          let matchB = bits[1].firstMatch(of: numb) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["DELV+2", "+3"] → ["DELV+2", "DELV+3"]                                                      ┆
  ┆     ["DELV+4", "+5"] → ["DELV+4", "DELV+5"]                                                      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let label = String(matchA.1)
                    let alpha = Int(String(matchA.2))!
                    let omega = Int(String(matchB.1))!

                    if omega-alpha == 1 {
                        result.append("\(label)+\(alpha)")
                    } else {
                        for i in alpha...omega { result.append("\(label)+\(i)") }
                    }
                    return result

                } else {
                    if bits[1].starts(with: "+") && bits[1].last != "D" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["AGSK", "+1"] → ["AGSK+0", "AGSK+1"]                                                        ┆
  ┆     ["TTF/8", "+1"] → ["TTF/8+0", "TTF/8+1"]                                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                        let offset = Int(bits[1].dropFirst())!
                        if offset == 1 {
                            result.append("\(bits[0])+\(offset-1)")         // "AGSK+0"
                        } else {
                            result.append("\(bits[0])+\(offset-1)")
                            result.append("\(bits[0])+\(offset)")
                        }
                        return result
                    }
                }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ×2z ["AGSBUFF+12", "GARBAGE"]                                                                    ┆
  ┆ ×2z ["AGSBUFF+12D", "GARBAGE"]                                                                   ┆
  ┆ ×2z ["AGSBUFF+13D", "GARBAGE"]                                                                   ┆
  ┆ ×2z ["AGSBUFF+7...+13D", "GARBAGE"]                                                              ┆
  ┆ ×2z ["MARKDOWN+6", "RM"]                                                                         ┆
  ┆ ×2z ["RANGERDOT+1", "GARBAGE"]                                                                   ┆
  ┆ ×2z ["SVMRKDAT+34", "GARBAGE"]                                                                   ┆
  ┆ ×2z ["TANGNB+1", "GARBAGE"]                                                                      ┆
  ┆ ×2z ["TSIGHT", "TSIGHT +1"]                                                                      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×2z \(bits)")

            case 3:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ×3  ["ADOT", "+1/OGARATE", "+1"]                                                                 ┆
  ┆ ×3  ["ADOT+2", "+3/OMEGAB+2", "+3"]                                                              ┆
  ┆ ×3  ["ADOT+4", "+5/OMEGAB+4", "+5"]                                                              ┆
  ┆ ×3  ["LAT(SPL)", "LNG(SPL)", "+1"]                                                               ┆
  ┆ ×3  ["WBODY", "...+5/OMEGAC", "...+5"]                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×3  \(bits)")

            case 4:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ×4  ["C31FLWRD", "FAILREG", "+1", "+2"]                                                          ┆
  ┆ ×4  ["CADRFLSH+2", "FAILREG", "+1", "+2"]                                                        ┆
  ┆ ×4  ["HAPO", "+1", "HPER", "+1"]                                                                 ┆
  ┆ ×4  ["HAPOX", "+1", "HPERX", "+1"]                                                               ┆
  ┆ ×4  ["LAT(SPL)", "+1", "LNG(SPL)", "+1"]                                                         ┆
  ┆ ×4  ["MARKDOWN", "+1...+5", "+6", "GARBAGE"]                                                     ┆
  ┆ ×4  ["MARKDOWN", "+1...+5", "+6", "RM"]                                                          ┆
  ┆ ×4  ["MKTIME", "+1", "RM", "+1"]                                                                 ┆
  ┆ ×4  ["NC1TIG", "+1", "NC2TIG", "+1"]                                                             ┆
  ┆ ×4  ["RANGE", "+1", "RRATE", "+1"]                                                               ┆
  ┆ ×4  ["REDOCTR", "THETAD", "+1", "+2"]                                                            ┆
  ┆ ×4  ["REDOCTR", "THETAD+0", "+1", "+2"]                                                          ┆
  ┆ ×4  ["TEPHEM", "+1", "+2", "GARBAGE"]                                                            ┆
  ┆ ×4  ["UTPIT", "+1", "UTYAW", "+1"]                                                               ┆
  ┆ ×4  ["VPRED", "+1", "GAMMAEI", "+1"]                                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×4  \(bits)")

            case 5:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ×5 ["COMPNUMB", "UPOLDMOD", "UPVERB", "UPCOUNT", "UPBUFF+0...+7"]                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×5  \(bits)")

            case 6:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ×6 ["CADRFLSH", "+1", "+2", "FAILREG", "+1", "+2"]                                           ┆
  ┆     ×6 ["LATANG", "+1", "RDOT", "+1", "THETAH", "+1"]                                            ┆
  ┆     ×6 ["OGC", "+1", "IGC", "+1", "MGC", "+1"]                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×6  \(bits)")

            default:
                logger.log("×\(bits.count)  \(bits)")

        }

    } else {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ comment text contains a "," and no "+"                                                           ┆
  ┆                                                                just split them (nothing special) ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if comment.contains(",") {
            return comment.split(separator: ",")
        } else {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ comment text contains no "," and no "+"                                                          ┆
  ┆                                                                                                  ┆
  ┆ -  APOGEE AND PERIGEE FROM R30   (28-29)                                                         ┆
  ┆ -  CDH AND CSI TIME                      (32-33)                                                 ┆
  ┆ -  CDH DELTA ALTITUDE			(74)                                                                     ┆
  ┆ -  CDH DELTA ALTITUDE                    (74)                                                    ┆
  ┆ -  CDH DELTA VELOCITY COMPONENTS   (98-100)                                                      ┆
  ┆ -  CSI DELTA VELOCITY COMPONENTS   (31-33)                                                       ┆
  ┆ -  FLAGWRD0 THRU FLAGWRD9                                                                        ┆
  ┆ -  FLAGWRDS 10 AND 11                                                                            ┆
  ┆ -  LANDING SITE MARK                                                                             ┆
  ┆ -  SPARE                                                                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            logger.log("-  \(comment)")
        }
    }

    return []
}

fileprivate func emitLine(_ i: Int = 999,
                          _ o: String,
                          _ a: String = "",
                          _ r: String = "",
                          _ p: String = "      ",
                          _ c: String = "") -> String {

    "\(String(format: "%03d", i)) : \(r.padTo16()) : \(a.padTo16()) : \(o) : \(p) : \(c)"
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ REGEXs                                                                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "^      2DNADR CMDAPMOD                     #   (034,036) # CMDAPMOD,PREL,QREL,RREL"         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let long = Regex {
    Anchor.startOfLine
    OneOrMore(.whitespace)
    Capture { OneOrMore(.word) }                                    // "2DNADR"
    OneOrMore(.whitespace)
    Capture { OneOrMore(.anyGraphemeCluster) }                      // "CMDAPMOD"
    "#"
    Capture { OneOrMore(.anyGraphemeCluster) }                      // "   (034,036) "
    "#"
    Capture { OneOrMore(.anyGraphemeCluster) }                      // "CMDAPMOD,PREL,QREL,RREL"
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "WORD█+m...+n" (where "█" is an optional " ")                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let code = Regex {
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/"))) }
    Optionally(" ")
    dots
    Optionally { OneOrMore(.word) }
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "WORD+m" (for example "AGSBUFF+0")                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let plus = Regex {
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/-"))) }
    "+"
    Capture { OneOrMore(.digit) }
    Optionally("D")
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "+m...+n"                                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let dots = Regex {
    numb
    "..."
    numb
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "+m"                                                                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let numb = Regex {
    Optionally("+")
    Capture { OneOrMore(.digit) }
    Optionally("D")
}

fileprivate func getPair(_ s: Substring) -> (Int, Int)? {
    guard let match = s.firstMatch(of: dots) else { return nil }
    return (Int(String(match.1))!, Int(String(match.2))!)
}
