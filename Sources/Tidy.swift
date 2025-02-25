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
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

func tidyFile(_ fileName: String, _ fileText: String) -> [String] {

    print("###  \((fileName.uppercased() + "  ").padding(toLength: 72, withPad: "=", startingAt: 0))")
    print("###     blank lines and page number lines removed   ")
    print("###  \(("").padding(toLength: 72, withPad: "=", startingAt: 0))\n")

    let oldLines = fileText.components(separatedBy: .newlines)
    var newLines: [String] = []
    var skipNextLine = false

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ drop blank lines (including blank comments) and page number lines ..                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    for line in oldLines {
        if skipNextLine { skipNextLine = false; continue }
        if line.isEmpty || line == "#" { continue }
        if line.contains("## Page ") { continue }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ keep comments                                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.starts(with: "#") {
            newLines.append(line)                           // "# ..."
            continue
        }
        
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ match assembler code                                                                             ┆
  ┆ ### SPECIAL CASE: one comment overflows to the next line so we fix it here ..                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var (label, opcode, comment) = doMatch(line)

        if comment.contains("COMPNUMB,UPOLDMOD,UPVERB,UPCOUNT,") {
            comment.append("UPBUFF+0...+7")
            skipNextLine = true
        }
        let reconstructedLine = "\(label.padTo10())\(opcode.padTo36())\(comment)"
        newLines.append(reconstructedLine)                  // "LABEL OPCODE ARGS   # ..."
    }

    return newLines
}
