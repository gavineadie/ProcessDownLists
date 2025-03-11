//
//  Tidy.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/9/25.
//

import Foundation
import RegexBuilder

func tidyFile(_ missionName: String, _ fileText: String) -> [String] {

    var oldLines = fileText.components(separatedBy: .newlines)
    var newLines: [String] = []

    var skipNextLine = false

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  scan the whole file for bulk replacements                                                       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    for lineNum in 0..<oldLines.count {
        let line = oldLines[lineNum]
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL SPECIAL CASE: three lines need clarifying .. processed in "Date" ..                  ┆
  ┆                                                                                                  ┆
  ┆     6DNADR SVMRKDAT                     # LANDING SITE MARK DATA                                 ┆
  ┆     6DNADR SVMRKDAT +12D                # SVMRKDAT+0...+34                                       ┆
  ┆     6DNADR SVMRKDAT +24D                # LANDING SITE MARK DATA                                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.contains("LANDING SITE MARK") {
            oldLines[lineNum+0] = "\t\t6DNADR\tSVMRKDAT\t\t\t# SVMRKDAT+0...+11"
            oldLines[lineNum+1] = "\t\t6DNADR\tSVMRKDAT +12D\t\t\t# SVMRKDAT+12...+23"
            oldLines[lineNum+2] = "\t\t6DNADR\tSVMRKDAT +24D\t\t\t# SVMRKDAT+24...+35"
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASE: substitute lines for AGS Initialization/Update (LM-77776)                      ┆
  ┆                                                                                                  ┆
  ┆ .. replaces:                                                                                     ┆
  ┆         3DNADR AGSBUFF +0                   #   (002-006) # AGSBUFF +0...+5                      ┆
  ┆         1DNADR AGSBUFF +12D                 #   (  008  ) # AGSBUFF +12D,GARBAGE                 ┆
  ┆         3DNADR AGSBUFF +1                   #   (010-014) # AGSBUFF +1...+6                      ┆
  ┆         1DNADR AGSBUFF +13D                 #   (  016  ) # AGSBUFF +13D, GARBAGE                ┆
  ┆         3DNADR AGSBUFF +6                   #   (018-022) # AGSBUFF +6...+11                     ┆
  ┆         1DNADR AGSBUFF +12D                 #   (  024  ) # AGSBUFF +12,GARBAGE                  ┆
  ┆         3DNADR AGSBUFF +7                   #   (026-030) # AGSBUFF +7...+12D                    ┆
  ┆         1DNADR AGSBUFF +13D                 #   (  032  ) # AGSBUFF +13D,GARBAGE                 ┆
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
    }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ drop blank lines (including blank comments) and page number lines ..                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    for var line in oldLines {
        if skipNextLine { skipNextLine = false; continue }

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

        let reconstructedLine = "\(label.padTo10())\(opcode.padTo36())\(comment)"
        newLines.append(reconstructedLine)                  // "LABEL OPCODE ARGS   # ..."
    }

    return newLines
}
