//
//  Tidy.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/9/25.
//

import Foundation

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │   LABEL           OPCODE                                  COMMENT                                │
  │   <--------------><--------------------------------------><--------------------------------      │
  │   LMRENDDL        EQUALS                                  # SEND ID BY SPECIAL CODING            │
  │                   DNPTR           LMREND01                # COLLECT SNAPSHOT                     │
  │                   DNPTR           LMREND02                # SEND SNAPSHOT                        │
  │                   2DNADR          DNLRVELX                # DNLRVELX,DNLRVELY,DNLRVELZ,DNLRALT   │
  │                   1DNADR          VN +2                   # VN +2,+3                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

func tidyFile(_ fileName: String, _ fileText: String) -> [String] {

    let oldLines = fileText.components(separatedBy: .newlines)
    var subLines: [String] = []
    var newLines: [String] = []
    var skipNextLine = false
    var skipSubLines = 0

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ drop blank lines (including blank comments) and page number lines ..                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    for var line in oldLines {
        if skipNextLine { skipNextLine = false; continue }
        if skipSubLines > 0 {
            line = subLines[3 - skipSubLines]
            skipSubLines -= 1
        }

        if line.isEmpty || line == "#" { continue }
        if line.contains("## Page ") { continue }

        line.replace("0-..+", with: "0...+")                        // typo fix
        line.replace("+0..+", with: "+0...+")                       // typo fix
        line.replace("FALG", with: "FLAG")                          // typo fix

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ keep comments                                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.starts(with: "#") {
            newLines.append(line)                                   // "# ..."
            continue
        }
        
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ match assembler code                                                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var (label, opcode, comment) = doMatch(line)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASE: one comment overflows to the next line so we fix it here ..                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if comment.contains("COMPNUMB,UPOLDMOD,UPVERB,UPCOUNT,") {
            comment.append("UPBUFF+0...+7")
            skipNextLine = true
        }

        if comment.contains("DAPDATR3,CH5FAIL,CH6FAIL,") {
            comment.append("DKRATE,DKDB,WHICHDAP")
            skipNextLine = true
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL SPECIAL CASE: three lines need clarifying ..                                         ┆
  ┆                                                                                                  ┆
  ┆     6DNADR SVMRKDAT                     # LANDING SITE MARK DATA                                 ┆
  ┆     6DNADR SVMRKDAT +12D                # SVMRKDAT+0...+34                                       ┆
  ┆     6DNADR SVMRKDAT +24D                # LANDING SITE MARK DATA                                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if comment.contains("LANDING SITE MARK") && skipSubLines == 0 {
            subLines = [
                "\t\t6DNADR\tSVMRKDAT\t\t\t# SVMRKDAT+0...+11",
                "\t\t6DNADR\tSVMRKDAT +12D\t\t\t# SVMRKDAT+12...+23",
                "\t\t6DNADR\tSVMRKDAT +24D\t\t\t# SVMRKDAT+24...+35"
            ]
            skipSubLines = subLines.count
            continue
        }

        let reconstructedLine = "\(label.padTo10())\(opcode.padTo36())\(comment)"
        newLines.append(reconstructedLine)                  // "LABEL OPCODE ARGS   # ..."
    }

    return newLines
}
