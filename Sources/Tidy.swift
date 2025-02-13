//
//  Tidy.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/9/25.
//

import Foundation

/*════════════════════════════════════════════════════════════════════════════════════════════════════*/

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
    let printURL = URL(fileURLWithPath: "/Users/gavin/Desktop/downlist/\(fileName)-tidy.txt")
    fileManager.createFile(atPath: printURL.path, contents: nil, attributes: nil)

    let originalStdout = dup(STDOUT_FILENO)

    if let fileHandle = try? FileHandle(forWritingTo: printURL) {
        defer { fileHandle.closeFile() }
        dup2(fileHandle.fileDescriptor, STDOUT_FILENO)
    }

    print("\n===  \((fileName.uppercased() + "  ").padding(toLength: 72, withPad: "=", startingAt: 0))")

    let oldLines = fileText.components(separatedBy: .newlines)
    var newLines: [String] = []
    
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ drop blank lines (including blank comments) and page number lines ..                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    for line in oldLines {
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
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let (label, opcode, comment) = doMatch(line)

        let reconstructedLine = "\(label.padTo10())\(opcode.padTo36())\(comment)"
        newLines.append(reconstructedLine)                  // "LABEL OPCODE ARGS   # ..."
    }

    newLines.forEach { print("\($0)") }

    dup2(originalStdout, STDOUT_FILENO)
    close(originalStdout)

    print("\(#function): Processed \(fileName).")

    return newLines
}
