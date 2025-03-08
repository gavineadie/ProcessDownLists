//
//  Data.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/24/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ║ .. the following line in Colossus237 implies two single precision words (wrong?)                 ║
  ║                 1DNADR LANDMARK                 #  LANDMARK,GARBAGE                              ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation
import RegexBuilder
import OSLog
        
let logger = Logger(subsystem: "com.ramsaycons.PDL", category: "data")

var order = 0

func dataFile(_ missionName: String, _ fileLines: [String]) -> [String] {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ process the lines of the file to isolate downlists ..                                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    var newLines: [String] = []

    for var line in fileLines {

        let ignoredPrefixes: Set<String> = ["# ", "#*"]
        if line.isEmpty || ignoredPrefixes.contains(where: line.hasPrefix) { continue }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ new downlink ..                                                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.starts(with: "##") { newLines.append(line); order = 0; continue }

        line.replace("SNAPSHOT", with: "")
        line.replace("COMMON DATA", with: "")
        line.replace("SNAPSHOT DATA", with: "")

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASE: these usages can be eliminated early ..                                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        line.replace("VGTIGX,Y,Z", with: "VGTIGX,VGTIGY,VGTIGZ")
        line.replace("VGVECT +0...+5", with: "VG VEC X,VG VEC Y,VG VEC Z")

        line.replace("TIME/1", with: "TIME2,TIME1")
        line.replace("TIME2/1", with: "TIME2,TIME1")

        line.replace("DISPLAY TABLES", with: "DSPTAB +0...+11")
        line.replace("DSPTAB TABLES", with: "DSPTAB +0...+11")

        line.replace("LAT(SPL),LNG(SPL),+1", with: "LAT(SPL),+1,LNG(SPL),+1")

        line.replace("UPBUFF+0,+1...+10,+11D", with: "UPBUFF +0...+11")
        line.replace("UPBUFF+12,+13...+18,+19D", with: "UPBUFF +12...+19")

        line.replace("OPTION1,2", with: "OPTION,+1")

        line.replace("/OGARATE", with: " (OGARATE")
        line.replace("/OMEGAB", with: " (OMEGAB")

        line.replace("RTARG,+1...+5", with: "RTARG +0...+5")

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASE: these (uncommon) usages can be eliminated early ..                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.contains("2DNADR CHANBKUP") { line.append("# CHANBKUP, +0...+3") }  // Luminary210

        line.replace("FLAGWRD0 THRU FLAGWRD9", with: "STATE +0...+9")               // Colossus237
        line.replace("FLAGWRDS 10 AND 11", with: "STATE +10...+11")                 // Colossus237

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ match an assembler line and split it into pieces:                                                │
  │                                                                                                  │
  │ "       2DNADR  CMDAPMOD                     #   (034,036) # CMDAPMOD,PREL,QREL,RREL"            │
  │         -----+  -------+                      ------------+  +----------------------             │
  │              |         |                                  |  |                                   │
  │              |         label: "CMDAPMOD"                  |  comment: "CMDAPMOD,PREL,QREL,RREL"  │
  │              |                                            |                                      │
  │              opCode: "2DNADR"                             range: "   (034,036) "                 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        if let match = line.firstMatch(of: long) {

            var opCode = String(match.1)
            let label = match.2.trimmingCharacters(in: .whitespaces)
            let range = String(match.3)
            let comment = match.4
                .replacingOccurrences(of: "DATA", with: "")                     // ← SPECIAL CASE
                .replacingOccurrences(of: "CHANNELS 76(GARBAGE),77", with: "GARBAGE,CHANNEL77")
                .replacingOccurrences(of: "APOGEE AND PERIGEE FROM R30", with: "HAPOX,HPERX")
                .replacingOccurrences(of: "CSI DELTA VELOCITY COMPONENTS", with: "DELVEET1 +0...+5")
                .replacingOccurrences(of: "CDH DELTA VELOCITY COMPONENTS", with: "DELVEET2 +0...+5")
                .replacingOccurrences(of: "CDH AND CSI TIME", with: "TCDH +0...+3")
                .replacingOccurrences(of: "CDH DELTA ALTITUDE", with: "DIFFALT")
                .trimmingCharacters(in: .whitespaces)

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ DNCHAN .. channel downlink ..                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
            if opCode == "DNCHAN" {
                if let match = comment.firstMatch(of: chNumb) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                                              "CHANNELS 13,14"                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    newLines.append(emitLine(order, range, opCode, "CHAN"+match.1, .single, comment))
                    newLines.append(emitLine(order, range, "      ", "CHAN"+match.2, .single, comment))

                } else if let match = comment.firstMatch(of: chWord) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                                              "CHANNELS GARBAGE,CHANNEL77"        ┆
  ┆                                                              "CHANNELS 76(GARBAGE),77"           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    newLines.append(emitLine(order, range, opCode, "GARBAGE", .single, comment))
                    newLines.append(emitLine(order, range, "      ", "CHAN"+match.1, .single, comment))

                }

                continue
            }

            if label == "SPARE" {
                newLines.append(emitLine(order, range, opCode, label, .double, comment))
            }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ split the comment field into bits ..                                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let commentBits = splitComment(label, comment)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     process nDNADR (n words in downlist)                                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let downCount = Int(String(opCode.first!))!

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL                                                                                      ┆
  ┆ .. a 6DNADR with eight variables -- only happens once (four singles and four doubles)            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if downCount == 6 && commentBits.count == 8 {

                for i in 0...3 {
                    newLines.append(emitLine(order, range, opCode,
                                             String(commentBits[i]),
                                             .single, comment))
                }
                for i in 4...7 {
                    newLines.append(emitLine(order, range, opCode,
                                             String(commentBits[i]),
                                             .double, comment))
                }
                continue
            }

            if downCount == commentBits.count/2 {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ SINGLE                                                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

                let shortLabel = upToPlus(label)
                if forceDouble.contains(shortLabel) {
                    let everyOtherBit = commentBits.enumerated()
                        .filter { $0.offset % 2 == 0 }.map { $0.element }

                    for bit in everyOtherBit {
                        newLines.append(emitLine(order, range, opCode,
                                                 String(bit),
                                                 .double, comment))
                        opCode = "      "
                    }

                } else {

                    for bit in commentBits {
                        newLines.append(emitLine(order, range, opCode,
                                                 String(bit),
                                                 .single, comment))
                        opCode = "      "
                    }
                }

                continue
            }

            if downCount == commentBits.count {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ DOUBLE                                                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                for bit in commentBits {
                    newLines.append(emitLine(order, range, opCode,
                                             String(bit),
                                             .double, comment))
                    opCode = "      "
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
                newLines.append(emitLine(order, range, i == 1 ? opCode : "      ",
                                         commentBits.count < downCount ? label : String(commentBits[i-1]),
                                         .double, comment))
                continue
            }

        }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ failed to match the assembler line WITH comment .. check for a line WITHOUT comment ..           │
  │                                                                                                  │
  │ "       2DNADR  CMDAPMOD                     #   (034,036)                                       │
  │         -----+  -------+                      ------------+                                      │
  │              |         |                                  |                                      │
  │              |         label: "CMDAPMOD"                  |                                      │
  │              |                                            |                                      │
  │              opCode: "2DNADR"                             range: "   (034,036) "                 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        if let match = line.firstMatch(of: noComment) {

            let opCode = String(match.1)
            let label = match.2.trimmingCharacters(in: .whitespaces)
            let range = String(match.3)

            newLines.append(emitLine(order, range, opCode, label, .double, ""))

        } else {
            logger.log("×X  \(line)")
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
  ┆                                                            split on "," and trim each sub-string ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var bits = comment.split(separator: ",")
            .map { $0.replacingOccurrences(of: " ", with: "") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ coagulate run-on uses "1...4,5" ← "1...5"                                                        ┆
  ┆     ### could be more clever and deal with "D" and missing "+"                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if bits.count == 3 { if bits[1...2] == ["+1...+4", "+5"] { bits = [bits[0], "+1...+5"] } }
        if bits.count == 3 { if bits[1...2] == ["+1...+5", "+6"] { bits = [bits[0], "+1...+6"] } }
        if bits.count == 3 { if bits[1...2] == ["+1...+10", "+11"] { bits = [bits[0], "+1...+11"] } }
        if bits.count == 3 { if bits[1...2] == ["+1...+10", "+11D"] { bits = [bits[0], "+1...+11"] } }
        if bits.count == 3 { if bits[1...2] == ["+13...+18", "+19D"] { bits = [bits[0], "+13...+19"] } }
        if bits.count == 3 { if bits[1...2] == ["13...+18", "19D"] { bits = [bits[0], "+13...+19"] } }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ "A","B/C","D" → "A","B","C","D"                                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if bits.count == 3 && bits[1].contains("/") {
            let twoBits = bits[1].split(separator: "/")
            bits.append(bits[2])
            bits[1] = String(twoBits[0])
            bits[2] = String(twoBits[1])
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ the parsing is tricky since characters are missing                                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if bits.count == 4 { if bits[1...3] == ["+1", "...+4", "+5"] { bits = [bits[0], "+1...+5"] } }
        if bits.count == 4 { if bits[1...3] == ["+1", "+2", "...+5"] { bits = [bits[0], "+1...+5"] } }
        if bits.count == 4 { if bits[1...3] == ["+1", "...+10", "+11"] { bits = [bits[0], "+1...+11"] } }

        switch bits.count {
            case 1:
                if let match = bits[0].firstMatch(of: code) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["A+m...+n"] → ["A", m, n] → ["A+m", "A+m", .. "A+n"]                                        ┆
  ┆                                                                                                  ┆
  ┆     ["GSAV+0...+5"] → ["GSAV", 0, 5] → ["GSAV+0", "GSAV+1", .., "GSAV+4", "GSAV+5"]              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let alpha = Int(String(match.2))!
                    let omega = Int(String(match.3))!
                    for i in alpha...omega { result.append("\(match.1)+\(i)") }
                    return result

                }

                logger.log("×1 \(bits)")

            case 2:
                if !bits[0].contains("+") && bits[1].contains("...") {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASE (ONLY ONE): "VGTIG,...+5" → "VGTIG,+1...+5"                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    if bits[1] == "...+5" { bits[1] = "+1...+5" }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["A", "+m...+n"] → ["A", m, n] → ["A+m", "A+m", .. "A+n"                                     ┆
  ┆                                                                                                  ┆
  ┆     ["DELV", "+1...+5"] → ["DELV+1", "DELV+2", "DELV+3", "DELV+4", "DELV+5"]                     ┆
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
  ┆     ["A+m", "+n"] → ["A", m, n] → ["A+m", "A+m", .. "A+n"]                                       ┆
  ┆                                                                                                  ┆
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

                } else if bits[1].starts(with: "+") && bits[1].last != "D" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["A", "+m"] → ["A", m] → ["A+0", "A+1", .. "A+m"]                                            ┆
  ┆                                                                                                  ┆
  ┆     ["AGSK", "+1"] → ["AGSK+0", "AGSK+1"]                                                        ┆
  ┆     ["TTF/8", "+1"] → ["TTF/8+0", "TTF/8+1"]                                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let offset = Int(bits[1].dropFirst())!
                    if offset == 1 {
                        result.append("\(bits[0])+\(offset-1)")         // "AGSK+0"
                        result.append("\(bits[0])+\(offset)")
                    } else {
                        logger.log("×2 (+\(offset)) \(bits)")           // doesn't happen
                    }
                    return result

                } else  {

                    for bit in bits {
                        if let match = bit.firstMatch(of: code) {           // "WORD␠+m...+n"
                            let alpha = Int(String(match.2))!
                            let omega = Int(String(match.3))!
                            for i in alpha...omega { result.append("\(match.1)+\(i)") }
                        } else if let match = bit.firstMatch(of: plus) {    // "WORD␠+m"
                            result.append("\(match.1)+\(match.2)")
                        } else {
                            result.append("\(bit)")
                        }
                    }
                    return result

                }

                logger.log("×2z \(bits)")

            case 4:
                if bits[1] == "+1" && bits[3] == "+1" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAME1", "+1", "NAME2", "+1"] → ["NAME1", "NAME2"]                                  doubles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    result.append("\(bits[0])")                     // "NAME1"
                    result.append("\(bits[2])")                     // "NAME2"
                    return result
                } else if bits[2] == "+1" && bits[3] == "+2" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAME1", "NAME2", "+1", "+2"] → ["NAME1", "NAME2+0", "NAME2+1", "NAME2+2"]          singles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    result.append("\(bits[0])")                     // "NAME1"
                    bits[1].replace("+0", with: "")
                    result.append("\(bits[1])+0")                   // "NAME2+0"
                    result.append("\(bits[1])+1")                   // "NAME2+1"
                    result.append("\(bits[1])+2")                   // "NAME2+2"
                    return result
                } else if bits[1] == "+1" && bits[2] == "+2" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAME1", "+1", "+2", "NAME2] → ["NAME1+0", "NAME1+1", "NAME1+2", "NAME2"]           singles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    result.append("\(bits[0])+0")                   // "NAME1+0"
                    result.append("\(bits[0])+1")                   // "NAME1+1"
                    result.append("\(bits[0])+2")                   // "NAME1+2"
                    result.append("\(bits[3])")                     // "NAME2"
                    return result
                } else {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAME1", "+1...+5", "+6", "NAME2] → ["NAME1+0", "NAME1+1", .., "NAME1+6", "NAME2"]  singles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    if let match = bits[1].firstMatch(of: dots) {
                        let alpha = Int(String(match.1))!
                        let omega = Int(String(match.2))!
                        for i in alpha...omega { result.append("\(bits[0])+\(i)") }
                        result.append("\(bits[0])+\(omega+1)")
                        result.append("\(bits[3])")                 // "NAME2"
                        return result
                    }
                }

                if let matchA = bits[0].firstMatch(of: plus),
                   let matchB = bits[1].firstMatch(of: numb),
                   let matchC = bits[2].firstMatch(of: plus),
                   let matchD = bits[3].firstMatch(of: numb) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAMEA+2", "+3", "NAMEB+2", "+3"] → ["NAMEA", "NAMEB"]                              doubles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    var label = String(matchA.1)
                    var alpha = Int(String(matchA.2))!
                    var omega = Int(String(matchB.1))!

                    if omega-alpha == 1 {
                        result.append("\(label)+\(alpha)")
                    } else {
                        for i in alpha...omega { result.append("\(label)+\(i)") }
                    }

                    label = String(matchC.1)
                    alpha = Int(String(matchC.2))!
                    omega = Int(String(matchD.1))!

                    if omega-alpha == 1 {
                        result.append("\(label)+\(alpha)")
                    } else {
                        for i in alpha...omega { result.append("\(label)+\(i)") }
                    }

                    return result

                }

                if !bits[0].contains("+") && bits[1].contains("...") &&
                    !bits[2].contains("+") && bits[3].contains("...") {
                    if bits[1] == "...+5" { bits[1] = "+0...+5" }               // ← SPECIAL CASE
                    if bits[3] == "...+5" { bits[3] = "+0...+5" }               // ← SPECIAL CASE
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NA", "...+5", "NB", "...+5"] → ["NA+0", .., "NA+3", ""NB+0", .., "NB+3"]           singles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    if let match = bits[1].firstMatch(of: dots) {
                        let alpha = Int(String(match.1))!
                        let omega = Int(String(match.2))!
                        for i in alpha...omega { result.append("\(bits[0])+\(i)") }
                    }

                    if let match = bits[3].firstMatch(of: dots) {
                        let alpha = Int(String(match.1))!
                        let omega = Int(String(match.2))!
                        for i in alpha...omega { result.append("\(bits[2])+\(i)") }
                    }

                    return result

                }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ×4  ["ADOT+2", "+3", "OMEGAB+2", "+3"]                                                           ┆
  ┆ ×4  ["ADOT+4", "+5", "OMEGAB+4", "+5"]                                                           ┆
  ┆ ×4  ["WBODY", "...+5", "OMEGAC", "...+5"]                                                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×4  \(bits)")

            case 5:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["COMPNUMB", "UPOLDMOD", "UPVERB", "UPCOUNT", "UPBUFF+0...+7"]                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                for i in 0...3 { result.append("\(bits[i])") }

                if let match = bits[4].firstMatch(of: code) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### this is tricky .. the first four variables are single precision occupying two words, so the  ┆
  ┆     remaining eight ("UPBUFF+0...+7") have to be double precision, hence:                        ┆
  ┆                              "UPBUFF+0...+7" → ["UPBUFF+0", "UPBUFF+2", "UPBUFF+4", "UPBUFF+6"]  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let alpha = Int(String(match.2))!
                    let omega = Int(String(match.3))!
                    for i in stride(from: alpha, through: omega, by: 2) { result.append("\(match.1)+\(i)") }
                    return result
                }

                logger.log("×5  \(bits)")

            case 6:
                if bits[1] == "+1" && bits[3] == "+1" && bits[5] == "+1" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAME1", "+1", "NAME2", "+1", "NAME3", "+1"] → ["NAME1", "NAME2, "NAME3"]           doubles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    result.append("\(bits[0])")                     // "NAME1"
                    result.append("\(bits[2])")                     // "NAME2"
                    result.append("\(bits[4])")                     // "NAME2"
                    return result
                } else if bits[1] == "+1" && bits[2] == "+2" &&
                          bits[4] == "+1" && bits[5] == "+2" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["N1", "+1", "+2", "N2", "+1", "+2"] → ["N1+0", .., "N1+2", "N2+0", .., "N2+2"]      singles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    result.append("\(bits[0])+0")                   // "N1+0"
                    result.append("\(bits[0])+1")                   // "N1+1"
                    result.append("\(bits[0])+2")                   // "N1+2"
                    result.append("\(bits[3])+0")                   // "N2+0"
                    result.append("\(bits[3])+1")                   // "N2+1"
                    result.append("\(bits[3])+2")                   // "N2+2"

                    return result
                }

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
                .map { Substring($0.trimmingCharacters(in: .whitespaces)) }
        }

        if let match = comment.wholeMatch(of: Regex { Capture { OneOrMore(.word) } }) {
            return [match.1]
        }

        if comment.contains(" ") {
            return [Substring(label)]
        }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ comment text contains no "," and no "+" (ERROR)                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

        logger.log("-  \(#function): '\(comment)'")

    }

    return []
}

enum Precision {
    case single
    case double
    case ignore
}

fileprivate func emitLine(_ ord: Int = 999,
                          _ ran: String = "",
                          _ opc: String,
                          _ adr: String = "",
                          _ pre: Precision = .double,
                          _ com: String = "") -> String {

    order += (pre == .double ? 2 : 1)

//    return """
//        \(String(format: "%03d", ord)) : \
//        \(ran.padTo16()) : \
//        \(adr.padTo16()) : \
//        \(opc) : \
//        \(pre == .double ? "double" : "single") : \
//        \(com)
//        """

    return """
        \(String(format: "%d", ord))\t\
        \(adr)\t\
        \(pre == .double ? "double" : "single") 
        """
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
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/.,+- "))) }  // "CMDAPMOD,PREL,QREL,RREL"
    Optionally {
        "("
        OneOrMore(.anyGraphemeCluster)
        ")"
    }
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "^      2DNADR CMDAPMOD                     #   (034,036)                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let noComment = Regex {
    Anchor.startOfLine
    OneOrMore(.whitespace)
    Capture { OneOrMore(.word) }                                    // "2DNADR"
    OneOrMore(.whitespace)
    Capture { OneOrMore(.anyGraphemeCluster) }                      // "CMDAPMOD"
    "#"
    Capture { OneOrMore(.anyGraphemeCluster) }                      // "   (034,036) "
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "WORD␠+m...+n" (where "␠" is an optional " ")                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let code = Regex {
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/-_"))) }
    Optionally(" ")
    dots
    Optionally { OneOrMore(.word) }
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "WORD␠+m" (for example "AGSBUFF+0" -- where "␠" is an optional " ")                          ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let plus = Regex {
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/-_"))) }
    Optionally(" ")
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

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "CHANNELS␠m,␠n"                                                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let chNumb = Regex {
    "CHANNEL"
    Optionally("S")
    Optionally(.whitespace)
    Capture { OneOrMore(.digit) }
    Optionally(.whitespace)
    ","
    Optionally(.whitespace)
    Capture { OneOrMore(.digit) }
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "CHANNELS GARBAGE,CHANNEL77"                                                                 ┆
  ┆     "CHANNELS 76(GARBAGE),77"                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let chWord = Regex {
    "GARBAGE"
    ","
    Optionally("CHANNEL")
    Capture { OneOrMore(.digit) }
}

func upToPlus(_ s: String) -> String {
    let upToPlus = Regex {
        Capture { OneOrMore(CharacterClass(.word, .anyOf("/-_"))) }
        Optionally { .anyGraphemeCluster }
    }

    if let match = s.firstMatch(of: upToPlus) { return String(match.1) } else { return s }
}

let forceDouble = [
    "AGSK",                     //### "K FACTOR" (GSOP)
    "CHANBKUP",
    "DELV",
    "DELVEET1",
    "DSPTAB",
    "GSAV",
    "REFSMMAT",
    "RLS",
    "RN",
    "STARSAV1",
    "STARSAV2",
    "STATE",
    "SVMRKDAT",
    "TCDH",
    "UPBUF",
    "UPBUFF",
    "VGTIG",
    "VN",
// 77774
    "DELLT4",
    "ELEV",
    "TCSI",
    "TPASS4",
    "DELVEET2",
    "DELVEET3",
    "DIFFALT",
    "TTPI",
    "RTARG",
    "TGO",
// 77773
    "LRVTIMDL",
    "VMEAS",
    "MKTIME",
    "HMEAS",
    "RM",
    "UNFC/2",
    "TTF/8",
    "DELTAH",
    "RGU",
    "VGU",
    "LAND",
    "AT",
    "TLAND",
    "TTOGO",

    "PIPTIME",                  //###
    "T-OTHER",                  //###
    "TALIGN",                   //###
    "TEVENT",                   //###
    "TIG",                      //###
    "V-OTHER"                   //###
]
