//
//  Join.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on Feb09/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ .. merge the "snapshot" and "common data" blocks into the "downlist" and writes to "*.join"      │
  │                                                                                                  │
  │ .. add three line header, eg:                                                                    │
  │                                                                                                  │
  │     ## ======================================================================================    │
  │     ## Apollo 13 LM [LM131R1] -- Coast and Align (LM-77777)                                      │
  │     ## ======================================================================================    │
  │                                                                                                  │
  │ .. add "title" line ..                                                                  ###APR07 │
  │                                                                                                  │
  │     Coast and Align                                                                              │
  │                                                                                                  │
  │ .. add ID,SYNC line which is not in the AGC code                                                 │
  │                                                                                                  │
  │                   1DNADR 77777                        #   (  000  )   1 # ID,SYNC                │
  │                                                                                                  │
  │ .. add index range and GSOP word number                                                 ###MAR12 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

var offset = 2                                      // starting offset into memory (0,1) is ID,SYNC

func joinFile(_ missionName: String) -> [String] {

    var newLines: [String] = []                     // the output lines from the function ..

    for (label, lines) in downlists.sorted(by: { $0.key < $1.key }) {

        let downListName = downListIDs[label] ?? "Unknown Downlist Label (XX-00000)"
        let downListCode = downListName.dropLast().suffix(5)
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ emit:                                                                                            ┆
  ┆                                                                                                  ┆
  ┆     ## ======================================================================================    ┆
  ┆     ## Apollo 13 LM [LM131R1] -- Coast and Align (LM-77777)                                      ┆
  ┆     ## ======================================================================================    ┆
  ┆     Coast and Align                                                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        newLines.append("## ".padding(toLength: 89, withPad: "=", startingAt: 0))
        newLines.append("## \(missionLookUp[missionName] ?? "?") [\(missionName)] -- \(downListName)")
        newLines.append("## ".padding(toLength: 89, withPad: "=", startingAt: 0))
        newLines.append("\(downListName.dropLast(11))")

        guard lines.isNotEmpty else {
            newLines.append("\(label.padTo10()) [MISSING]")
            continue
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ emit necessary first line:                                                                       ┆
  ┆               1DNADR 77777                        #   (  000  )   1 # ID,SYNC                    ┆
  ┆     |         |                                   |                                              ┆
  ┆     1 ...     11 ...                              47 ...                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        newLines.append("\(" ".padTo10())\("1DNADR \(downListCode)".padTo36())#   (  000  )   1 # ID,SYNC")
        offset = 2

        for line in lines {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ break every line (again -- please factor this) because we need info from the OPCODE ..           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let (label, instruction, comment) = matchAssembler(line)

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "DNPTR" indicates a need to copy a list into the DOWNLIST ..                 NO DATA IN DOWNLIST │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
            if instruction.contains("DNPTR") {                   //### SundanceXXX has a "-DNPTR"
                newLines.append("#       → \(instruction.padTo36())#   (  ---  )     \(comment)")

                let operand = instruction.split(separator: " ")[1]
                guard let copyList = lookUpList(String(operand)) else {
                    newLines.append("# copylist: \(operand) missing")
                    continue
                }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ map the SNAPSHOT or COPYLIST lines to Label/Instruction/Comment ..                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                let lablInstCommArray = copyList.map { matchAssembler( $0 ) }

                if lablInstCommArray.first!.1.starts(with: "-") {         // "-DNADR → "SNAPSHOT
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ SNAPSHOT                                                                                         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
                    let instruction = String(lablInstCommArray.first!.1.drop(while: { $0 == "-" }))
                    if instruction.contains("DNTMBUFF") {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ignore "DNTMBUFF" ..                                                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                        newLines.append("#*      → \(instruction.padTo36())                  \(comment)")
                        continue
                    }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for a SNAPSHOT emit the last line first ..                                                       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    newLines.append("""
                            \(" ".padTo10())\
                            \(lablInstCommArray.last!.1.dropFirst().padTo36())\
                            # s \(mem_mem(instruction)) \
                            \(lablInstCommArray.last!.2)
                            """)
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ .. then lines 1 to last-1 ..                                                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    lablInstCommArray[0..<copyList.count-1].forEach {
                        let opcode = String($0.1.drop(while: { $0 == "-" }))
                        newLines.append("""
                                \(" ".padTo10())\
                                \(opcode.padTo36())\
                                # s \(mem_mem(opcode)) \
                                \($0.2)
                                """)
                    }
                } else {                                            // COPYLIST
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ COPYLIST                                                                                         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
                    lablInstCommArray.forEach {
                        let opcode = String($0.1.drop(while: { $0 == "-" }))
                        if opcode.contains("DNTMBUFF") {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ignore "DNTMBUFF" ..                                                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                            newLines.append("#*      → \(opcode.padTo36())                  \(comment)")
                        } else {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for a COPYLIST emit the lines in order ..                                                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                            newLines.append("""
                                \(" ".padTo10())\
                                \(opcode.padTo36())\
                                # c \(mem_mem(opcode)) \
                                \($0.2)
                                """)
                        }
                    }
                }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ an address referring to "DNTMBUFF" can be marked as a comment ..             NO DATA IN DOWNLIST │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
            } else if instruction.contains("DNTMBUFF") {
                newLines.append("#*      → \(instruction.padTo36())                  \(comment)")

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ emit a line from the main DOWNLIST ..                                                            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
            } else {
                newLines.append("""
                    \(label.padTo10())\
                    \(instruction.drop(while: { $0 == "-" }).padTo36())\
                    #   \(mem_mem(instruction)) \
                    \(comment)
                    """)
            }
        }

        newLines.append("")
    }

    return newLines
}

fileprivate func lookUpList(_ address: String) -> [String]? {

    if let copyList = copylists[String(address)] { return copyList }
    if let copyList = copylists[String(equalities[address]!)] { return copyList }

    return nil
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ OPCODEs of the form "nDNADR" contribute "n" words to the data in the DOWNLIST                    │
  │ .. generate a string of one of the forms "(  034  )", "(034,036)", "(034-044)"                   │
  │ .. add the GSOP numbering                                                               ###MAR12 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
fileprivate func mem_mem(_ opcode: String) -> String {

    var result = "         "

    let lowerIndex = String(format: "%03d", offset)
    let gsopIndex = String(format: "%3d", offset/2+1)

    if opcode.starts(with: "DNCHAN") {
        result = "(  \(lowerIndex)  ) \(gsopIndex)"
        offset += 2
    }

    if let match = opcode.firstMatch(of: #/(\d)DNADR/#), let n = Int(String(match.1)) {
        let upperIndex = String(format: "%03d", offset+(n-1)*2)

        switch n {
            case 1:
                result = "(  \(lowerIndex)  ) \(gsopIndex)"
            case 2:
                result = "(\(lowerIndex),\(upperIndex)) \(gsopIndex)"
            case 3...6:
                result = "(\(lowerIndex)-\(upperIndex)) \(gsopIndex)"
            default:
                break
        }
        offset += n*2
    }

    return result
}
