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

func joinFile(_ missionName: String) -> [String] {

    var newLines: [String] = []

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
    if let copyList = copylists[String(equalities[address]!)] { return copyList }

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

let missionLookUp = [
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  Command Modules ..                                                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    "Colossus237" : "Apollo 8 CM - Colossus 1",                     // R-577-sec2-rev2.pdf (p2-20)
    "Colossus249" : "Apollo 9 CM - Colossus 1A",                    // R-577-sec2-rev2.pdf
    "Comanche044" : "Apollo 10 CM - Colossus 2 (not flown)",
    "Comanche045" : "Apollo 10 CM - Colossus 2 (not flown)",
    "Manche45R2"  : "Apollo 10 CM - Colossus 2",
    "Comanche051" : "Apollo 11 CM - Colossus 2A (not flown)",
    "Comanche055" : "Apollo 11 CM - Colossus 2A",
    "Comanche067" : "Apollo 12 CM - Colossus 2C",
    "Comanche072" : "Apollo 13 CM - Colossus 2D (not flown)",
    "Manche72R3"  : "Apollo 13 CM - Colossus 2D",
    "Artemis072"  : "Apollo 15/16/17 CM - Colossus 3",
    "Skylark084"  : "Skylab 2/3/4 CM",
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  Command Modules ..                                                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    "Sundance306" : "Apollo 9 (not flown)",
    "SundanceXXX" : "Apollo 9",
    "Luminary069" : "Apollo 10 LM - Luminary 1",
    "Luminary096" : "Apollo 11 LM - Luminary 1A (not flown)",
    "Luminary097" : "Apollo 11 LM - Luminary 1A (not flown)",
    "Luminary098" : "Apollo 11 LM - Luminary 1A (not flown)",
    "Luminary099" : "Apollo 11 LM - Luminary 1A",
    "Luminary116" : "Apollo 12 LM - Luminary 1B",
    "Luminary130" : "Apollo 13 LM - Luminary 1C (not flown)",
    "Luminary131" : "Apollo 13 LM - Luminary 1C",                   // R-567-sec2-rev8.pdf
    "Zerlina56"   : "Experimental LM (not flown)",
    "Luminary163" : "Apollo 14 LM - Luminary 1D (not flown)",
    "Luminary173" : "Apollo 14 LM - Luminary 1D (not flown)",
    "Luminary178" : "Apollo 14 LM - Luminary 1D",
    "Luminary210" : "Apollo 15/16/16 LM - Luminary 1E"              // R-567-sec2-rev12.pdf
]
