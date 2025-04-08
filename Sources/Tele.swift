//
//  Tele.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on Mar07/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation
import RegexBuilder

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ .. reads from "*.xtra.tsv" file and writes one "*.swift" file per downlist ..                    │
  │╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌│
  │ IMPORTANT .. We depend on the fist three lines being of the form show below (three comments)     │
  │                                                                                                  │
  │  find the line ranges for each downlist ..                                                       │
  │     ## ======================================================================================    │
  │     ## Apollo 11 LM - Luminary 1A (not flown) [Luminary096] -- Descent and Ascent (LM-77773)     │
  │     ## ======================================================================================    │
  │╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌│
  │ from:                                                                                            │
  │     52|X789|B5|FMT_SP|FormatEarthOrMoonDP|TBD                                                    │
  │                                                                                                  │
  │ generate:                                                                                        │
  │     tmFormat( 24, "   DNRRANGE",              vType: .single, FormatRrRange),                    │
  │     tmFormat( 14, "    T-OTHER",  x2²⁸, "cS", vType: .double),      //S│  CSM Time (cSec/2²⁸     │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func teleFile(_ missionName: String, _ fileLines: [String]) {

    let fileManager = FileManager.default

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  read the "xtra" file into memory and split into downlist groups ..                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    var fileMemory = [String]()
    for line in fileLines { fileMemory.append(line) }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ each downlist starts with a line starting "## ====" ..                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    var firstLines = fileMemory.enumerated()
        .filter { $0.element.hasPrefix("## ====") }
        .map { $0.offset }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ .. but there is a second line starting "## ====" so only keep the odd offsets ..                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    firstLines = firstLines.enumerated()
        .filter { $0.offset % 2 == 0 }
        .map { $0.element }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ split the lines of the whole file into ranges for each downlist ..                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    var lineRanges = [ClosedRange<Int>]()
    for i in 0..<firstLines.count-1 {
        lineRanges.append(firstLines[i]...firstLines[i+1]-1)
    }
    lineRanges.append(firstLines[firstLines.count-1]...fileMemory.count-1)

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ process each downlist ..                                                                         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    for lineRange in lineRanges {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ add top three comment lines .. and extract downlist ID ("7777n") ..                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var content = ""
        let downListID = fileLines[lineRange.lowerBound+1].suffix(6).dropLast()

        content.append("""
        //
        //  \(fileLines[lineRange.lowerBound+1].dropFirst(3))
        //  \(missionName.lowercased())_\(downListID).swift
        //
        //  Created by Gavin Eadie on \(Date().formatted(date: .abbreviated, time: .omitted)) (copyright 2024-25)
        //
        let \(missionName.lowercased())_\(downListID) = FormatTable(
            listName: "\(fileLines[lineRange.lowerBound+1].dropFirst(3))",
            downList: [
        
        """)

        for line in fileLines[lineRange.lowerBound+3...lineRange.upperBound] {

            if line.hasPrefix("#") { continue }

            if let match = line.firstMatch(of: tabbedLine) {

                let index = Int(match.1)!
                let label = leftPad(String(match.2), 11)
                let units = match.6 == "TBD" ? "" : "\"" + match.6 + "\", "
                let scale = leftPad(scaleLookup[String(match.3)] ?? String(match.3), 12-units.count) + ","
                let format = match.4
                let special = match.5

                let newLine = """
                        tmFormat(\
                \(String(format: "%3d", index)), \
                "\(label)", \
                \(scale) \
                \(units)\
                vType: \(formatLookup[String(format)] ?? ".ignore")\
                \(special == "" ? ")," : ", " + lookupSpecial[String(special)]! + "),")
                """
                content.append(newLine + "\n")


            } else {
                print("line not matching: \(line)")
            }

        }

        content += """
               ]
            )
            
            """

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ put all the subfile lines back together and write them to "ddd-id-mission.tsv" ..                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let swiftDirectory = fileManager.urls(for: .desktopDirectory,
                                               in: .userDomainMask).first {
            let fileURL = swiftDirectory
                .appendingPathComponent("downlist")
                .appendingPathComponent("swift")
                .appendingPathComponent("\(missionName)_\(downListID).swift")

            do {
                try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
                print("File successfully written to: \(fileURL.path)")
            } catch {
                print("Error writing to file: \(error)")
            }
        } else {
            print("Could not find the documents directory.")
        }
    }
}

fileprivate func lowerFirst(_ s: String) -> String {
    guard let first = s.first else { return s }
    return String(first).lowercased() + s.dropFirst()
}

fileprivate let tabbedLine = Regex {
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

fileprivate let formatLookup = [
    "FMT_SP" : ".single",
    "FMT_DP" : ".double",
    "FMT_OCT" : ".oneOct",
    "FMT_DEC" : ".oneDec",
    "FMT_2OCT" : ".twoOct",
    "FMT_2DEC" : ".twoDec",
]

fileprivate let scaleLookup = [
    "B29" : "x2²⁹",
    "B28" : "x2²⁸",
    "B27" : "x2²⁷",
//  "B26" : "x2²⁶",
    "B25" : "x2²⁵",
    "B24" : "x2²⁴",

//  "B23" : "x2²³",
//  "B22" : "x2²²",
//  "B21" : "x2²¹",
//  "B20" : "x2²⁰",
//  "B19" : "x2¹⁹",
    "B18" : "x2¹⁹",
    "B17" : "x2¹⁵",
    "B16" : "x2¹⁶",

    "B15" : "0x8000",
    "B14" : "x2¹⁴",
//  "B13" : "x2¹³",
//  "B12" : "x2¹²",
//  "B11" : "x2¹¹",
    "B10" : "x2¹⁰",
    "B9"  : "x2⁹",
//  "B8"  : "x2⁸",

    "B7"  : "x2⁷",
    "B6"  : "x2⁶",
    "B5"  : "x2⁵",
//  "B4"  : "x2⁴",
//  "B3"  : "8",
//  "B2"  : "4",
    "B1"  : "2",
    "B0"  : "1"
]

fileprivate let lookupSpecial = [
    "FormatAdotsOrOga"    : "formatAdotsOrOga",
    "FormatDELV"          : "formatΔV",
    "FormatEarthOrMoonDP" : "formatEarthOrMoonDP",
    "FormatEarthOrMoonSP" : "formatEarthOrMoonSP",
    "FormatEpoch"         : "formatEpoch",
    "FormatGtc"           : "formatGtc",
    "FormatHalfDP"        : "formatHalfDP",
    "FormatHMEAS"         : "formatHMEAS",
    "FormatLrRange"       : "formatLrRange",
    "FormatLrVx"          : "formatLrVx",
    "FormatLrVy"          : "formatLrVy",
    "FormatLrVz"          : "formatLrVz",
    "FormatOTRUNNION"     : "formatOTrunnion",
    "FormatRDOT"          : "formatRdot",
    "FormatRrRange"       : "fmtRadarRange",
    "FormatRrRangeRate"   : "fmtRadarRangeRate",
    "FormatXACTOFF"       : "formatXACTOFF"
]


let lookupGsopNames: [Substring : Substring] = [
    "AGSK"          : "K-FACTOR",
    "AIG"           : "CDU Y",
    "AMG"           : "CDU Z",
    "AOG"           : "CDU X",
    "AOTCODE"       : "AOT CODE",
    "BESTI"         : "STAR1 ID",
    "BESTJ"         : "STAR2 ID",
    "CDUS"          : "RR SHAFT",
    "CDUT"          : "RR TRUNN",
    "CDUXD"         : "CDU XD",
    "CDUYD"         : "CDU YD",
    "CDUZD"         : "CDU ZD",
    "DNRRANGE"      : "RR RANGE",
    "DNRRDOT"       : "RR RRATE",
    "DELLT4"        : "TF CONIC",
    "REDOCTR"       : "REDO CTR",
    "RLS"           : "L SITE X",
    "RLS+2"         : "L SITE Y",
    "RLS+4"         : "L SITE Z",
    "TRKMKCNT"      : "MARK CNT",

    "DELVEET"       : "CSI dV X",
    "DELVEET+2"     : "CSI dV Y",
    "DELVEET+4"     : "CSI dV Z",

    "TCSI"          : "CSI TIME",
    "DELVEET1"      : "CSI dV X",
    "DELVEET1+2"    : "CSI dV Y",
    "DELVEET1+4"    : "CSI dV Z",

    "TCDH"          : "CDH TIME",
    "DELVEET2"      : "CDH dV X",
    "DELVEET2+2"    : "CDH dV Y",
    "DELVEET2+4"    : "CDH dV Z",

    "TTPI"          : "TPI TIME",
    "DELVEET3"      : "TPI dV X",
    "DELVEET3+2"    : "TPI dV Y",
    "DELVEET3+4"    : "TPI dV Z",

    "TPASS4"        : "TPF TIME",

    "X789"          : "d BETA",
    "X789+2"        : "d THETA",

    "LASTYCMD"      : "RR T ERR",
    "LASTXCMD"      : "RR S ERR",

    "RGU"           : "RX GUIDE",
    "RGU+2"         : "RY GUIDE",
    "RGU+4"         : "RZ GUIDE",
    "VGU"           : "VX GUIDE",
    "VGU+2"         : "VY GUIDE",
    "VGU+4"         : "VZ GUIDE",

    "UNFC/2"        : "THRUST X",
    "UNFC/2+2"      : "THRUST Y",
    "UNFC/2+4"      : "THRUST Z",

    "RM"            : "VHF R ##",
    "DELTAR"        : "OFFSET P",

    "LAT"           : "LAND LAT",
    "LONG"          : "LAND LON",
    "ALT"           : "LAND ALT",

    "8NN"           : "MARK CNT",

    "MARKDOWN"      : "S1 TIME",
    "MARKDOWN+2"    : "S1 Y CDU",
    "MARKDOWN+3"    : "S1 SHAFT",
    "MARKDOWN+4"    : "S1 Z CDU",
    "MARKDOWN+5"    : "S1 TRUNN",
    "MARKDOWN+6"    : "S1 X CDU",

    "MARK2DWN"      : "S2 TIME",
    "MARK2DWN+2"    : "S2 Y CDU",
    "MARK2DWN+3"    : "S2 SHAFT",
    "MARK2DWN+4"    : "S2 Z CDU",
    "MARK2DWN+5"    : "S2 TRUNN",
    "MARK2DWN+6"    : "S2 X CDU",
]

