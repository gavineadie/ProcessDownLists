//
//  Sort.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 3/7/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

func sortFile(_ missionName: String, _ fileLines: [String]) {

    let fileManager = FileManager.default

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  read the "xtra" file into memory and split into tsv files ..                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

    var fileMemory = [String]()

    for line in fileLines { fileMemory.append(line) }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ IMPORTANT .. We depend on the fist three lines being of the form show below (three comments)     ┆
  ┆                                                                                                  ┆
  ┆  find the line ranges for each downlist ..                                                       ┆
  ┆     ## ======================================================================================    ┆
  ┆     ## Apollo 11 LM - Luminary 1A (not flown) [Luminary096] -- Descent and Ascent (LM-77773)     ┆
  ┆     ## ======================================================================================    ┆
  ┆     0   ID          B0    FMT_OCT            TBD                                      ^^^^^      ┆
  ┆     1   SYNC        B0    FMT_OCT            TBD                                                 ┆
  ┆     2   LRXCDUDL    360   FMT_SP             TBD                                                 ┆
  ┆     3   LRYCDUDL    360   FMT_SP             TBD                                                 ┆
  ┆     4   LRZCDUDL    360   FMT_SP             TBD                                                 ┆
  ┆      : : : : : : : : : :                                                                         ┆
  ┆      : : : : : : : : : :                                                                         ┆
  ┆     192 DELV+4      B14   FMT_DP FormatDELV  TBD                                                 ┆
  ┆     194 PSEUDO55    B14   FMT_SP FormatGtc   TBD                                                 ┆
  ┆     # offset 195 is unused                                                                       ┆
  ┆     196 TTOGO       B28   FMT_DP             TBD                                                 ┆
  ┆     ## ======================================================================================    ┆
  ┆     ## Apollo 11 LM - Luminary 1A (not flown) [Luminary096] -- Surface Align (LM-77772)          ┆
  ┆     ## ======================================================================================    ┆
  ┆     0   ID          B0    FMT_OCT            TBD                                      ^^^^^      ┆
  ┆     1   SYNC        B0    FMT_OCT            TBD                                                 ┆
  ┆     2   LRXCDUDL    360   FMT_SP             TBD                                                 ┆
  ┆     3   LRYCDUDL    360   FMT_SP             TBD                                                 ┆
  ┆     4   LRZCDUDL    360   FMT_SP             TBD                                                 ┆
  ┆      : : : : : : : : : :                                                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

    var firstLines = fileMemory.enumerated()
        .filter { $0.element.hasPrefix("## ====") }
        .map { $0.offset }

    firstLines = firstLines.enumerated()
        .filter { $0.offset % 2 == 0 }
        .map { $0.element }

    var lineRanges = [ClosedRange<Int>]()
    for i in 0..<firstLines.count-1 {
        lineRanges.append(firstLines[i]...firstLines[i+1]-1)
    }
    lineRanges.append(firstLines[firstLines.count-1]...fileMemory.count-1)


    var downListID: Substring
    for lineRange in lineRanges {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ add top three comment lines ..                                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var content = fileLines[lineRange.lowerBound...lineRange.lowerBound+2].joined(separator: "\n")

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ add https line .. based on missionName & downListCode                                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        downListID = fileLines[lineRange.lowerBound+1].suffix(6).dropLast()
        if let missionListURL = getMissionListURL(missionName, String(downListID)) {
            content += "\n" + missionListURL + "\n"
        } else {
            content += "\n"
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ put all the subfile lines back together and write them to "ddd-id-mission.tsv" ..                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        content += fileLines[lineRange.lowerBound+3...lineRange.upperBound].joined(separator: "\n")

        if let tsvDirectory = fileManager.urls(for: .desktopDirectory,
                                               in: .userDomainMask).first {
            let fileURL = tsvDirectory
                .appendingPathComponent("downlist")
                .appendingPathComponent("tsv")
                .appendingPathComponent("ddd-\(downListID)-\(missionName).tsv")

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
