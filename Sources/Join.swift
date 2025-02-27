//
//  Join.swift
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

var offset = 2                  // offset into memory

func joinFile(_ fileName: String) -> [String] {

    var newLines: [String] = []

    for (label, lines) in downlists.sorted(by: { $0.key < $1.key }) {

        let downListName = downListIDs[label] ?? "Unknown Downlist Label (XX-00000)"
        let downListCode = downListName.dropLast().suffix(5)

        newLines.append("## ".padding(toLength: 78, withPad: "=", startingAt: 0))
        newLines.append("## \(fileName) -- \(downListName)")
        newLines.append("## ".padding(toLength: 78, withPad: "=", startingAt: 0))
        newLines.append("")

        offset = 2

        guard lines.isNotEmpty else {
            newLines.append("\(label.padTo10()) [MISSING]")
            continue
        }

        let opCode = "1DNADR \(downListCode)"
        newLines.append("\(" ".padTo10())\(opCode.padTo36())#   (  000  ) # ID,SYNC")

        for line in lines {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ break every line (again -- please factor this) because we need info from the OPCODE ..           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let (label, opcode, comment) = doMatch(line)

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "DNPTR" indicates a need to copy a list into the DOWNLIST ..                 NO DATA IN DOWNLIST │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
            if opcode.contains("DNPTR") {                   //### SundanceXXX has a "-DNPTR"
                newLines.append("#       → \(opcode.padTo36())#   (  ---  ) \(comment)")

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
                        newLines.append("#*      → \(opcode.padTo36())              \(comment)")
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
                            newLines.append("#*      → \(opcode.padTo36())              \(comment)")
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
                newLines.append("#*      → \(opcode.padTo36())              \(comment)")

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
    if let copyList = copylists[String(equalites[address]!)] { return copyList }

    return nil
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ OPCODEs of the form "nDNADR" contribute "n" words to the data in the DOWNLIST                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func mem_mem(_ opcode: String) -> String {

    var result = "         "

    if opcode.starts(with: "DNCHAN") {
        result = "(  \(String(format: "%03d", offset))  )"
        offset += 2
    }

    if let match = opcode.firstMatch(of: #/(\d)DNADR/#), let n = Int(String(match.1)) {
        switch n {
            case 1:
                result = "(  \(String(format: "%03d", offset))  )"
            case 2:
                result = "(\(String(format: "%03d", offset)),\(String(format: "%03d", offset+(n-1)*2)))"
            case 3...6:
                result = "(\(String(format: "%03d", offset))-\(String(format: "%03d", offset+(n-1)*2)))"
            default:
                break
        }
        offset += n*2
    }

    return result
}
