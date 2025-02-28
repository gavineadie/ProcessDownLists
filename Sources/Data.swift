//
//  Data.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/24/25.
//

import Foundation
import RegexBuilder

var order = 0

func dataFile(_ fileName: String, _ fileLines: [String]) -> [String] {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ process the lines of the file to isolate downlists ..                                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    var newLines: [String] = []

    for var line in fileLines {

        guard line.isNotEmpty else { continue }
        if line.starts(with: "# ") || line.starts(with: "#*") { continue }
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
        line.replace("TIME/1", with: "TIME2,+1")
        line.replace("TIME2/1", with: "TIME2,+1")

        line.replace("DISPLAY TABLES", with: "DSPTAB +0...+11")
        line.replace("DSPTAB TABLES", with: "DSPTAB +0...+11")

        line.replace("LAT(SPL),LNG(SPL),+1", with: "LAT(SPL),+1,LNG(SPL),+1")

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
                .replacingOccurrences(of: "CHANNELS 76(GARBAGE),77", with: "GARBAGE,CHANNEL77")
                .trimmingCharacters(in: .whitespaces)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ DNCHAN .. channel downlink ..                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if opCode == "DNCHAN" {
                if let match = comment.firstMatch(of: chNumb) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                                              "CHANNELS 13,14"                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    newLines.append(emitLine(order, range, opCode, "CHAN"+match.1, .byte, comment))
                    newLines.append(emitLine(order, range, "      ", "CHAN"+match.2, .byte, comment))

                    continue
                } else if let match = comment.firstMatch(of: chWord) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                                              "CHANNELS GARBAGE,CHANNEL77"        ┆
  ┆                                                              "CHANNELS 76(GARBAGE),77"           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    newLines.append(emitLine(order, range, opCode, "GARBAGE", .byte, comment))
                    newLines.append(emitLine(order, range, "      ", "CHAN"+match.1, .byte, comment))

                    continue
                }

//                logger.log("×C  \(comment)")

            }

            if comment == "SPARE" {
                newLines.append(emitLine(order, range, opCode, "SPARE", .byte, comment))

                continue
            }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ split the comment field into bits ..                                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let commentBits = splitComment(label, comment)

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

                let shortLabel = upToPlus(label)
                if ["REFSMMAT", "RLS", "VGTIG", "STATE", "DELVEET1", "DSPTAB", "STARSAV1", "STARSAV2",
                    "RN", "VN", "UPBUF", "UPBUFF"].contains(shortLabel) {
                    let everyOtherBit = commentBits.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }

                    for bit in everyOtherBit {
                        newLines.append(emitLine(order, range, opCode,
                                                 String(bit),
                                                 .word, comment))
                        opCode = "      "
                    }

                } else {

                    for bit in commentBits {
                        newLines.append(emitLine(order, range, opCode,
                                                 String(bit),
                                                 .byte, comment))
                        opCode = "      "
                    }
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
                    newLines.append(emitLine(order, range, opCode,
                                             String(bit),
                                             .word, comment))
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
                                         .word, comment))

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

        if bits.count == 3 && bits[1].contains("/") {
            let twoBits = bits[1].split(separator: "/")
            bits.append(bits[2])
            bits[1] = String(twoBits[0])
            bits[2] = String(twoBits[1])
        }

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

                }

//                logger.log("×1 \(bits)")

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
//                        logger.log("×2a \(bits)")
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

                } else if bits[1].starts(with: "+") && bits[1].last != "D" {
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

//                logger.log("×2z \(bits)")

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
//                logger.log("×4  \(bits)")

            case 5:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["COMPNUMB", "UPOLDMOD", "UPVERB", "UPCOUNT", "UPBUFF+0...+7"]                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                for i in 0...3 { result.append("\(bits[i])") }

                if let match = bits[4].firstMatch(of: code) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                                   "UPBUFF+0...+7" → ["UPBUFF+0", .., "UPBUFF+7"] ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let alpha = Int(String(match.2))!
                    let omega = Int(String(match.3))!
                    for i in alpha...omega { result.append("\(match.1)+\(i)") }
                    return result
                }

//                logger.log("×5  \(bits)")

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

//                logger.log("×6  \(bits)")

            default:
//                logger.log("×\(bits.count)  \(bits)")
                break

        }

    } else {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ comment text contains a "," and no "+"                                                           ┆
  ┆                                                                just split them (nothing special) ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if comment.contains(",") {
            return comment.split(separator: ",")
        }

        if let match = comment.wholeMatch(of: #/(\w+)/#) {
            return [match.1]
        }
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

//        logger.log("-  \(comment)")

    }

    return []
}

enum Precision {
    case byte
    case word
}

fileprivate func emitLine(_ ord: Int = 999,
                          _ ran: String = "",
                          _ opc: String,
                          _ adr: String = "",
                          _ pre: Precision = .word,
                          _ com: String = "") -> String {

    order += (pre == .word ? 2 : 1)

    return """
        \(String(format: "%03d", ord)) : \
        \(ran.padTo16()) : \
        \(adr.padTo16()) : \
        \(opc) : \
        \(pre == .word ? "double" : "single") : \
        \(com)
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
    Capture { OneOrMore(.anyGraphemeCluster) }                      // "CMDAPMOD,PREL,QREL,RREL"
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "WORD␠+m...+n" (where "␠" is an optional " ")                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let code = Regex {
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/"))) }
    Optionally(" ")
    dots
    Optionally { OneOrMore(.word) }
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "WORD␠+m" (for example "AGSBUFF+0" -- where "␠" is an optional " ")                          ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let plus = Regex {
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/-"))) }
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
        Capture { OneOrMore(.word) }
        Optionally { .anyGraphemeCluster }
    }

    if let match = s.firstMatch(of: upToPlus) { return String(match.1) } else { return s }
}
