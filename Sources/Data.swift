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
        if line.starts(with: "##") { newLines.append(line); index = 0; continue }

        line = line.replacingOccurrences(of: "SNAPSHOT", with: "")
        line = line.replacingOccurrences(of: "COMMON DATA", with: "")
        line = line.replacingOccurrences(of: "SNAPSHOT DATA", with: "")

        if line.contains("SPARE") { line.append("# SPARE") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     2DNADR CMDAPMOD                     #   (034,036) # CMDAPMOD,PREL,QREL,RREL                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let match = line.firstMatch(of: #/^\s+(\w+)\s+(.+)#(.+)#(.+)/#) {

            var opCode = String(match.1)
            var param = match.2.trimmingCharacters(in: .whitespaces)
            if param == "SPARE" { param = " " }
            let range = String(match.3)
            let comment = match.4
                .replacingOccurrences(of: "DATA", with: "")
                .trimmingCharacters(in: .whitespaces)

            let commentBits = splitComment(comment)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     process nDNADR (n words in downlist)                                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if let downCount = Int(String(opCode.first!)) {                     // nDNADR

                if downCount == commentBits.count/2 {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     2DNADR CMDAPMOD                     #   (034,036) # CMDAPMOD,PREL,QREL,RREL                  ┆
  ┆                                                         ^^^^^^^^^^^^^^^^^^^^^^^                  ┆
  ┆                                             we have half-words (two comment bits per downCount)  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    for bit in commentBits {
                        newLines.append(emitLine(index, opCode,
                                                 String(bit), range,
                                                 "single", comment))
                        opCode = "      "
                        index += 1
                    }

//                } else if downCount == commentBits.count {
                } else {

                    newLines.append(emitLine(index, opCode,
                                             param, range,
                                             "double", comment))
                    index += 2

                    if downCount > 1 {
                        for _ in 2...downCount {
                            newLines.append(emitLine(index, "      ",
                                                     param, range,
                                                     "double", comment))
                            index += 2
                        }
                    }

                }

            } else {
                newLines.append(emitLine(index, opCode,
                                         param, range,
                                         "double", comment))        // DNCHAN
                index += 2
            }

        } else {
            newLines.append(line)
        }

    }

    return newLines
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
fileprivate func splitComment(_ comment: String) -> [Substring] {
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
                if let match = bits[0].firstMatch(of: line) {
                    let alpha = Int(String(match.2))!
                    let omega = Int(String(match.3))!
                    for i in alpha...omega { result.append("\(match.1)+\(i)") }

//                    logger.log("+1 \(bits) → \(result)")

                    return result
                } else {
                    logger.log("×1 \(bits)")
                }

            case 2:
                if bits[1].contains("...") {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ×2 ["RTARG", "+1...+5"]                                                                      ┆
  ┆     ×2 ["STARSAV1+0...+5", "STARSAV2+0...+5"]                                                    ┆
  ┆     ×2 ["VGTIG", "...+5"]                         ### VGTIGX,Y,Z ?                               ┆
  ┆     ×2 ["VGTIG", "+1...+5"]                                                                      ┆
  ┆     ×2 ["YNBSAV+0...+5", "ZNBSAV +0...+5"]                                                       ┆
  ┆     ×2 ["YNBSAV+0...+5", "ZNBSAV+0...+5"]                                                        ┆
  ┆     ×2 ["DELV", "+1...+5"]                                                                       ┆
  ┆     ×2 ["DELVEET3", "+1...+5"]                                                                   ┆
  ┆     ×2 ["DELVSLV", "+1...+5"]                                                                    ┆
  ┆     ×2 ["MARK2DWN", "+1...+6"]                                                                   ┆
  ┆     ×2 ["REFSMMAT", "+1...+11"]                                                                  ┆
  ┆     ×2 ["RLS", "+1...+5"]                                                                        ┆
  ┆     ×2 ["UPBUFF", "+1...+11"]                                                                    ┆
  ┆     ×2 ["UPBUFF+0", "+1...+11"]                                                                  ┆
  ┆     ×2 ["UPBUFF+12", "+13...+19"]                                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    logger.log("×2 \(bits)")
                } else if let matchA = bits[0].firstMatch(of: plus),
                          let matchB = bits[1].firstMatch(of: numb) {

                    let label = matchA.1
                    let alpha = Int(String(matchA.2))!
                    let omega = Int(String(matchB.1))!
                    for i in alpha...omega { result.append("\(label)+\(i)") }

//                    logger.log("+2 \(bits) → \(result)")

                    return result

                } else {
                    if bits[1].starts(with: "+") && bits[1].last != "D" {
                        let offset = Int(bits[1].dropFirst())!
                        result.append("\(bits[0])+\(offset-1)")
                        result.append("\(bits[0])+\(offset)")

//                        logger.log("+2 \(bits) → \(result)")

                        return result
                    }
                }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ×2 ["AGSBUFF+12", "GARBAGE"]                                                                 ┆
  ┆     ×2 ["AGSBUFF+12D", "GARBAGE"]                                                                ┆
  ┆     ×2 ["AGSBUFF+13D", "GARBAGE"]                                                                ┆
  ┆     ×2 ["AGSBUFF+7...+13D", "GARBAGE"]                                                           ┆
  ┆     ×2 ["MARKDOWN+6", "RM"]                                                                      ┆
  ┆     ×2 ["RANGERDOT+1", "GARBAGE"]                                                                ┆
  ┆     ×2 ["SVMRKDAT+34", "GARBAGE"]                                                                ┆
  ┆     ×2 ["TANGNB+1", "GARBAGE"]                                                                   ┆
  ┆     ×2 ["TSIGHT", "TSIGHT +1"]                                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×2 \(bits)")

            case 3:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ×3 ["ADOT", "+1/OGARATE", "+1"]                                                              ┆
  ┆     ×3 ["ADOT+2", "+3/OMEGAB+2", "+3"]                                                           ┆
  ┆     ×3 ["ADOT+4", "+5/OMEGAB+4", "+5"]                                                           ┆
  ┆     ×3 ["LAT(SPL)", "LNG(SPL)", "+1"]                                                            ┆
  ┆     ×3 ["WBODY", "...+5/OMEGAC", "...+5"]                                                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×3 \(bits)")

            case 4:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ×4 ["C31FLWRD", "FAILREG", "+1", "+2"]                                                       ┆
  ┆     ×4 ["CADRFLSH+2", "FAILREG", "+1", "+2"]                                                     ┆
  ┆     ×4 ["HAPO", "+1", "HPER", "+1"]                                                              ┆
  ┆     ×4 ["HAPOX", "+1", "HPERX", "+1"]                                                            ┆
  ┆     ×4 ["LAT(SPL)", "+1", "LNG(SPL)", "+1"]                                                      ┆
  ┆     ×4 ["MARKDOWN", "+1...+5", "+6", "GARBAGE"]                                                  ┆
  ┆     ×4 ["MARKDOWN", "+1...+5", "+6", "RM"]                                                       ┆
  ┆     ×4 ["MKTIME", "+1", "RM", "+1"]                                                              ┆
  ┆     ×4 ["NC1TIG", "+1", "NC2TIG", "+1"]                                                          ┆
  ┆     ×4 ["RANGE", "+1", "RRATE", "+1"]                                                            ┆
  ┆     ×4 ["REDOCTR", "THETAD", "+1", "+2"]                                                         ┆
  ┆     ×4 ["REDOCTR", "THETAD+0", "+1", "+2"]                                                       ┆
  ┆     ×4 ["TEPHEM", "+1", "+2", "GARBAGE"]                                                         ┆
  ┆     ×4 ["UTPIT", "+1", "UTYAW", "+1"]                                                            ┆
  ┆     ×4 ["VPRED", "+1", "GAMMAEI", "+1"]                                                          ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×4 \(bits)")

            case 5:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ×5 ["COMPNUMB", "UPOLDMOD", "UPVERB", "UPCOUNT", "UPBUFF+0...+7"]                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×5 \(bits)")

            case 6:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ×6 ["CADRFLSH", "+1", "+2", "FAILREG", "+1", "+2"]                                           ┆
  ┆     ×6 ["LATANG", "+1", "RDOT", "+1", "THETAH", "+1"]                                            ┆
  ┆     ×6 ["OGC", "+1", "IGC", "+1", "MGC", "+1"]                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                logger.log("×6 \(bits)")

            default:
                logger.log("×\(bits.count) \(bits)")

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
  ┆     - CDH AND CSI TIME                      (32-33)                                              ┆
  ┆     - CDH DELTA ALTITUDE			(74)                                                                  ┆
  ┆     - CDH DELTA ALTITUDE                    (74)                                                 ┆
  ┆     - CDH DELTA VELOCITY COMPONENTS   (98-100)                                                   ┆
  ┆     - CSI DELTA VELOCITY COMPONENTS   (31-33)                                                    ┆
  ┆     - DISPLAY TABLES                                                                             ┆
  ┆     - DSPTAB TABLES                                                                              ┆
  ┆     - FLAGWRD0 THRU FLAGWRD9                                                                     ┆
  ┆     - FLAGWRDS 10 AND 11                                                                         ┆
  ┆     - LANDING SITE MARK                                                                          ┆
  ┆     - SPARE                                                                                      ┆
  ┆     - TIME/1                                                                                     ┆
  ┆     - TIME2/1                                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            logger.log("- \(comment)")
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
  ┆     "WORD█+m...+n" (where "█" is an optional " ")                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let line = Regex {
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/"))) }
    Optionally(" ")
    dots
    Optionally { OneOrMore(.word) }
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "WORD+m" (for example "AGSBUFF+0")                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let plus = Regex {
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/"))) }
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
