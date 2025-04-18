//
//  Tidy.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on Feb09/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation
import RegexBuilder

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ .. reads from "DOWNLINK_LISTS.agc" file and writes to "*.tidy"                                   │
  │                                                                                                  │
  │╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌│
  │     ## Page 196                                                                                  │
  │     # LM COAST AND ALIGNMENT DOWNLIST                                                            │
  │     #                                                                                            │
  │     # -----------------  CONTROL LIST  --------------------------                                │
  │                                                                                                  │
  │     LMCSTADL     EQUALS                                   # SEND ID BY SPECIAL CODING            │
  │                  DNPTR      LMCSTA01                      # COLLECT SNAPSHOT                     │
  │                  6DNADR     DNTMBUFF                      # SEND SNAPSHOT                        │
  │                  1DNADR     AGSK                          # AGSK,+1                              │
  │                  1DNADR     TALIGN                        # TALIGN,+1                            │
  │                  2DNADR     POSTORKU                      # POSTORKU,NEGTORKU,POSTORKV,NEGTORKV  │
  │                  1DNADR     DNRRANGE                      # DNRRANGE,DNRRDOT                     │
  │     <LABEL>      <OPCODE>   <OPERAND>    <MOD>            <COMMENT     ..>                       │
  │╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌│
  │                                                                                                  │
  │ .. scan the whole file for bulk replacements.  To avoid complications related to adding or       │
  │    removing lines, the replacements don't add or remove lines.                                   │
  │                                                                                                  │
  │ .. delete blank lines, blank comment lines and page number lines ..                              │
  │                                                                                                  │
  │ .. where a comment overflows to the next line (two cases), unwrap them ..                        │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

func tidyFile(_ missionName: String, _ fileText: String) -> [String] {

    var oldLines = fileText.components(separatedBy: .newlines)
    var newLines: [String] = []

    var skipNextLine = false

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  scan the whole file for bulk replacements replacing the original lines (oldLines) in place. To  │
  │  avoid complications related to adding or removing lines, the replacements don't add or remove   │
  │  lines.                                                                                          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    for lineNum in 0..<oldLines.count {
        let line = oldLines[lineNum]
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL SPECIAL CASE: three lines need clarifying .. processed in "Data" ..                  ┆
  ┆                                                                                                  ┆
  ┆                  6DNADR     SVMRKDAT                      # LANDING SITE MARK DATA               ┆
  ┆                  6DNADR     SVMRKDAT     +12D             # SVMRKDAT+0...+34                     ┆
  ┆                  6DNADR     SVMRKDAT     +24D             # LANDING SITE MARK DATA               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.contains("LANDING SITE MARK") {
            oldLines[lineNum+0] = "\t\t6DNADR\tSVMRKDAT\t\t\t# SVMRKDAT+0...+11"
            oldLines[lineNum+1] = "\t\t6DNADR\tSVMRKDAT +12D\t\t\t# SVMRKDAT+12...+23"
            oldLines[lineNum+2] = "\t\t6DNADR\tSVMRKDAT +24D\t\t\t# SVMRKDAT+24...+35"
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASE                     [Luminary099, LM131R1, Zerlina56, Luminary163, Luminary210] ┆
  ┆                                                             AGS Initialization/Update (LM-77776) ┆
  ┆ .. replace:                                                                                      ┆
  ┆                  3DNADR     AGSBUFF      +0               # AGSBUFF +0...+5                      ┆
  ┆                  1DNADR     AGSBUFF      +12D             # AGSBUFF +12D,GARBAGE                 ┆
  ┆                  3DNADR     AGSBUFF      +1               # AGSBUFF +1...+6                      ┆
  ┆                  1DNADR     AGSBUFF      +13D             # AGSBUFF +13D, GARBAGE                ┆
  ┆                  3DNADR     AGSBUFF      +6               # AGSBUFF +6...+11                     ┆
  ┆                  1DNADR     AGSBUFF      +12D             # AGSBUFF +12,GARBAGE                  ┆
  ┆                  3DNADR     AGSBUFF      +7               # AGSBUFF +7...+12D                    ┆
  ┆                  1DNADR     AGSBUFF      +13D             # AGSBUFF +13D,GARBAGE                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.contains(Regex {
            "AGSBUFF"
            ZeroOrMore(.whitespace)
            "+0..."
        }) {
            oldLines[lineNum+0] = "\t\t3DNADR\tLMEMBER\t\t\t# LM X POS,GARBAGE,LM Y POS,GARBAGE,LM Z POS,GARBAGE"
            oldLines[lineNum+1] = "\t\t1DNADR\tLM EPOCH\t\t\t# LM EPOCH"
            oldLines[lineNum+2] = "\t\t3DNADR\tLMEMBER\t\t\t# LM X VEL,GARBAGE,LM Y VEL,GARBAGE,LM Z VEL,GARBAGE"
            oldLines[lineNum+3] = "\t\t1DNADR\tLMEMBER\t\t\t# GARBAGE,GARBAGE"
            oldLines[lineNum+4] = "\t\t3DNADR\tCMEMBER\t\t\t# CM X POS,GARBAGE,CM Y POS,GARBAGE,CM Z POS,GARBAGE"
            oldLines[lineNum+5] = "\t\t1DNADR\tCM EPOCH\t\t\t# CM EPOCH"
            oldLines[lineNum+6] = "\t\t3DNADR\tCMEMBER\t\t\t# CM X VEL,GARBAGE,CM Y VEL,GARBAGE,CM Z VEL,GARBAGE"
            oldLines[lineNum+7] = "\t\t1DNADR\tCMEMBER\t\t\t# GARBAGE,GARBAGE"
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASE (same as above but it is a snapshot, so all "1DNADR")         [Sundance306ish]  ┆
  ┆                                                             AGS Initialization/Update (LM-77776) ┆
  ┆ .. replace:                                                                                      ┆
  ┆                                                                                                  ┆
  ┆     LMAGSI01     -1DNADR    AGSBUFF      +2               # AGSBUFF+2,+3             SNAPSHOT    ┆
  ┆                  1DNADR     AGSBUFF      +4               # AGSBUFF+4,+5                         ┆
  ┆                  1DNADR     AGSBUFF      +12D             # AGSBUFF+12D,GARBAGE                  ┆
  ┆                  1DNADR     AGSBUFF      +1               # AGSBUFF+1,+2                         ┆
  ┆                  1DNADR     AGSBUFF      +3               # AGSBUFF+3,+4                         ┆
  ┆                  1DNADR     AGSBUFF      +5               # AGSBUFF+5,+6                         ┆
  ┆                  1DNADR     AGSBUFF      +13D             # AGSBUFF+13D, GARBAGE                 ┆
  ┆                  1DNADR     AGSBUFF      +6               # AGSBUFF+6,+7                         ┆
  ┆                  1DNADR     AGSBUFF      +8D              # AGSBUFF+8D,+9D                       ┆
  ┆                  1DNADR     AGSBUFF      +10D             # AGSBUFF+10D,+11D                     ┆
  ┆                  1DNADR     AGSBUFF      +12D             # AGSBUFF+12,GARBAGE                   ┆
  ┆                  -1DNADR    AGSBUFF                       # AGSBUFF+0,+1                         ┆
  ┆                                                                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.contains(Regex {
            "-1DNADR"
            OneOrMore(.whitespace)
            "AGSBUFF"
            OneOrMore(.whitespace)
            "+2"
        }) {
            oldLines[lineNum+0] = "LMAGSI01\t-1DNADR\tLLMEMBER\t\t\t# LM Y POS,GARBAGE"
            oldLines[lineNum+1] = "\t\t1DNADR\tLMEMBER\t\t\t# LM Z POS,GARBAGE"
            oldLines[lineNum+2] = "\t\t1DNADR\tLM EPOCH\t\t\t# LM EPOCH"
            oldLines[lineNum+3] = "\t\t1DNADR\tLMEMBER\t\t\t# LM X VEL,GARBAGE"
            oldLines[lineNum+4] = "\t\t1DNADR\tLMEMBER\t\t\t# LM Y VEL,GARBAGE,"
            oldLines[lineNum+5] = "\t\t1DNADR\tLMEMBER\t\t\t# LM Z VEL,GARBAGE"
            oldLines[lineNum+6] = "\t\t1DNADR\tLMEMBER\t\t\t# GARBAGE,GARBAGE"
            oldLines[lineNum+7] = "\t\t3DNADR\tCMEMBER\t\t\t# CM X POS,GARBAGE,CM Y POS,GARBAGE,CM Z POS,GARBAGE"
            oldLines[lineNum+8] = "\t\t1DNADR\tCM EPOCH\t\t\t# CM EPOCH"
            oldLines[lineNum+9] = "\t\t3DNADR\tCMEMBER\t\t\t# CM X VEL,GARBAGE,CM Y VEL,GARBAGE,CM Z VEL,GARBAGE"
            oldLines[lineNum+10] = "\t\t1DNADR\tCMEMBER\t\t\t# GARBAGE,GARBAGE"
            oldLines[lineNum+11] = "\t\t-1DNADR\tLMEMBER\t\t\t# LM X POS,GARBAGE"
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ .. also, because a snapshot can only gather 12 words, another line in this downlist brings in    ┆
  ┆    four more.  We remove that line                                                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.contains(Regex {
            "4DNADR"
            OneOrMore(.whitespace)
            "AGSBUFF"
            OneOrMore(.whitespace)
            "+7"
        }) {
            oldLines[lineNum+0] = "# REMOVE '   4DNADR AGSBUFF  +7'"
        }
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ now process all the lines in the file (including the replacements) ..                            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    for var line in oldLines {
        if skipNextLine { skipNextLine = false; continue }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ drop blank lines, blank comment lines and page number lines ..                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.isEmpty || line == "#" || line.contains("## Page ") { continue }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ correct some fairly common typos ..                                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        line.replace("0-..+", with: "0...+")                            // typo fix
        line.replace("+0..+", with: "+0...+")                           // typo fix
        line.replace("FALG", with: "FLAG")                              // typo fix
        line.replace("CHANNEL11 ,12", with: "CHANNELS11,12")            // Zerlina52 ###TYPO

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ keep comment lines .. append to output and loops back to read next line ..                       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.starts(with: "#") {
            newLines.append(line)                                       // "# ..."
            continue
        }
        
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ match assembler code                                                                             ┆
  ┆                  3DNADR     AGSBUFF      +1               # AGSBUFF +1...+6                      ┆
  ┆     <1 label>    <2 opcode+operand+mod --->               < 3 comment --------------------->     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var (label, instruction, comment) = matchAssembler(line)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASE: where a comment overflows to the next line (two cases) we fix them here ..     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if comment.contains("COMPNUMB,UPOLDMOD,UPVERB,UPCOUNT,") {      // all the Luminary files
            comment.append("UPBUFF+0...+7")
            skipNextLine = true
        }

        if comment.contains("DAPDATR3,CH5FAIL,CH6FAIL,") {              // only the Skylark048 file
            comment.append("DKRATE,DKDB,WHICHDAP")
            skipNextLine = true
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ emit a new assembler code line ..                                                                ┆
  ┆     LOWIDCOD  OCT 77340                           # LOW ID CODE                                  ┆
  ┆     |         |                                   |                                              ┆
  ┆     1 ...     11 ...                              47 ...                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let reconstructedLine = "\(label.padTo10())\(instruction.padTo36())\(comment)"
        newLines.append(reconstructedLine)
    }

    return newLines
}
