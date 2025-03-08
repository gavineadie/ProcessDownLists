//
//  Tele.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 3/7/25.
//

import Foundation
import RegexBuilder

func teleFile(_ missionName: String, _ fileLines: [String]) -> [String] {

    guard missionName == "Luminary131" else { return [] }

    print("""
            //
            //  lm77776.swift
            //  Telemetry
            //
            //  Created by Gavin Eadie on Nov16/24 (copyright 2024-25)
            //

            /*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
              │ Lunar Module AGS initialization and Update downlink list                                         │
              │                                                                                                  │
              │      P27 LGC Update                                                                 → (LM-77777) │
              │      R47 AGS Initialization                          → Lunar Module Orbital Maneuvers (LM-77774) │
              └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

            let lm77776 = FormatTable(
                listName: "Lunar Module AGS Initialization and Update (LM-77776)",
                downList: [
            """)

    var newLines: [String] = []

    for line in fileLines {

        if line.hasPrefix("#") {
            newLines.append(line)
            continue
        }

        if let match = line.firstMatch(of: tabbedLine) {

            let index = Int(match.1)!
            let label = leftPad(String(match.2), 11)
            let units = match.6 == "TBD" ? "" : "\"" + match.6 + "\", "
            let scale = String(match.3) == "B0" ?
                    "            " :
                    leftPad(scaleLookup[String(match.3)] ?? String(match.3), 11-units.count) + ","
            let format = match.4
            let special = match.5

            let newLine = """
                        tmFormat(\
                \(String(format: "%3d", index)), \
                "\(label)", \
                \(scale) \
                \(units)\
                vType: \(formatLookup[String(format)] ?? ".unknow")\
                \(special == "" ? ")," : ", " + special + "),")
                """
//            print("    line matching: \(newLine)")
            newLines.append(newLine)


        } else {
            print("line not matching: \(line)")
        }

    }

    return newLines
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ generate:                                                                                        │
  │     tmFormat( 24, "   DNRRANGE",              vType: .single, FormatRrRange),                    │
        tmFormat( 14, "    T-OTHER",  x2²⁸, "cS", vType: .double),      //S│  CSM Time (cSec/2²⁸
    from:
        52|X789|B5|FMT_SP|FormatEarthOrMoonDP|TBD

  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
let tabbedLine = Regex {
    Regex {
        Capture { OneOrMore { .digit } }                // index
        "\t"
        Capture { OneOrMore { .anyGraphemeCluster} }    // label
        "\t"
        Capture { OneOrMore { .word } }                 // scale
        "\t"
        Capture { OneOrMore { .word } }                 // format
        "\t"
        Capture { Optionally { OneOrMore { .word } } }  // special
        "\t"
        Capture { OneOrMore { .anyGraphemeCluster} }    // units
    }}

let formatLookup = [
    "FMT_SP" : ".single",
    "FMT_DP" : ".double",
    "FMT_OCT" : ".oneOct",
    "FMT_DEC" : ".oneDec",
    "FMT_2OCT" : ".twoOct",
    "FMT_2DEC" : ".twoDec",
]

func leftPad(_ s: String, _ n: Int) -> String {
    return (s.count <= 11) ? String(repeating: " ", count: n - s.count) + s : s
}

let scaleLookup = [
    "B25" : "x2²⁵",
    "B18" : "0x40000",
    "B15" : "0x8000",
    "B7" : "x2⁷",
]
