//
//  Join.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/9/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ .. parse                                                                                         │
  │                                                                                                  │
  │   LABEL           OPCODE                                  COMMENT                                │
  │   <--------------><--------------------------------------><--------------------------------      │
  │   LMRENDDL        EQUALS                                  # SEND ID BY SPECIAL CODING            │
  │                   DNPTR           LMREND01                # COLLECT SNAPSHOT                     │
  │                   DNPTR           LMREND02                # SEND SNAPSHOT                        │
  │                   2DNADR          DNLRVELX                # DNLRVELX,DNLRVELY,DNLRVELZ,DNLRALT   │
  │                   1DNADR          VN +2                   # VN +2,+3                             │
  │                                                                                                  │
  │ .. add three line header, eg:                                                                    │
  │                                                                                                  │
  │     ## ======================================================================================    │
  │     ## Apollo 13 LM [LM131R1] -- Coast and Align (LM-77777)                                      │
  │     ## ======================================================================================    │
  │                                                                                                  │
  │ .. add ID,SYNC line which is not in the AGC code                                                 │
  │                                                                                                  │
  │                   1DNADR 77777                        #   (  000  )   1 # ID,SYNC                │
  │                                                                                                  │
  │ .. merge the "snapshot" and "common data" blocks into the "downlist"                             │
  │                                                                                                  │
  │ .. add index range and GSOP word number                                                 ###MAR12 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

var offset = 2                                      // starting offset into memory (0,1) is ID,SYNC

func joinFile(_ missionName: String) -> [String] {

    var newLines: [String] = []                     // the output lines from the function ..

    for (label, lines) in downlists.sorted(by: { $0.key < $1.key }) {

        let downListName = downListIDs[label] ?? "Unknown Downlist Label (XX-00000)"
        let downListCode = downListName.dropLast().suffix(5)

        newLines.append("## ".padding(toLength: 89, withPad: "=", startingAt: 0))
        newLines.append("## \(missionLookUp[missionName] ?? "?") [\(missionName)] -- \(downListName)")
        newLines.append("## ".padding(toLength: 89, withPad: "=", startingAt: 0))
        newLines.append("")

        offset = 2

        guard lines.isNotEmpty else {
            newLines.append("\(label.padTo10()) [MISSING]")
            continue
        }

        newLines.append("\(" ".padTo10())\("1DNADR \(downListCode)".padTo36())#   (  000  )   1 # ID,SYNC")

        for line in lines {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ break every line (again -- please factor this) because we need info from the OPCODE ..           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let (label, opcode, comment) = doMatch(line)

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "DNPTR" indicates a need to copy a list into the DOWNLIST ..                 NO DATA IN DOWNLIST │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
            if opcode.contains("DNPTR") {                   //### SundanceXXX has a "-DNPTR"
                newLines.append("#       → \(opcode.padTo36())#   (  ---  )     \(comment)")

                let address = opcode.split(separator: " ")[1]
                guard let copyList = lookUpList(String(address)) else {
                    newLines.append("# copylist: \(address) missing")
                    continue
                }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ is it a SNAPSHOT or COPYLIST? ..                                                                 ┆
  ┆                                                    .. mark the comment of the inclusion with "|" ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                let tripleArray = copyList.map { doMatch( $0 ) }

                if tripleArray.first!.1.starts(with: "-") {         // SNAPSHOT

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for a SNAPSHOT print the last line first ..                                                      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let opcode = String(tripleArray.first!.1.drop(while: { $0 == "-" }))
                    if opcode.contains("DNTMBUFF") {
                        newLines.append("#*      → \(opcode.padTo36())                  \(comment)")
                        continue
                    }
                    newLines.append("""
                            \(" ".padTo10())\
                            \(tripleArray.last!.1.dropFirst().padTo36())\
                            # s \(mem_mem(opcode)) \
                            \(tripleArray.last!.2)
                            """)

                    tripleArray[0..<copyList.count-1].forEach {
                        let opcode = String($0.1.drop(while: { $0 == "-" }))
                        newLines.append("""
                                \(" ".padTo10())\
                                \(opcode.padTo36())\
                                # s \(mem_mem(opcode)) \
                                \($0.2)
                                """)
                    }
                } else {                                            // COPYLIST
                    tripleArray.forEach {
                        let opcode = String($0.1.drop(while: { $0 == "-" }))
                        if opcode.contains("DNTMBUFF") {
                            newLines.append("#*      → \(opcode.padTo36())                  \(comment)")
                        } else {
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
            } else if opcode.contains("DNTMBUFF") {
                newLines.append("#*      → \(opcode.padTo36())                  \(comment)")

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ a line from the main DOWNLIST ..                                                                 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
            } else {
                newLines.append("""
                    \(label.padTo10())\
                    \(opcode.drop(while: { $0 == "-" }).padTo36())\
                    #   \(mem_mem(opcode)) \
                    \(comment)
                    """)
            }
        }

        newLines.append("")
    }

    return newLines
}

func lookUpList(_ address: String) -> [String]? {

    if let copyList = copylists[String(address)] { return copyList }
    if let copyList = copylists[String(equalities[address]!)] { return copyList }

    return nil
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ OPCODEs of the form "nDNADR" contribute "n" words to the data in the DOWNLIST                    │
  │ .. generate a string of one of the forms "(  034  )", "(034,036)", "(034-044)"                   │
  │ .. add the GSOP numbering                                                               ###MAR12 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func mem_mem(_ opcode: String) -> String {

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
