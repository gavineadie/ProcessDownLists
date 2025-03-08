//
//  Sort.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 3/7/25.
//

import Foundation

func sortFile(_ fileName: String, _ fileLines: [String]) {

    let fileManager = FileManager.default

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  read the "xtra" file into memory and split into tsv files ..                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

    var fileMemory = [String]()

    for line in fileLines { fileMemory.append(line) }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  find the line ranges for each downlist ..                                                       ┆
  ┆     ## ======================================================================================    ┆
  ┆     ## Apollo 11 LM - Luminary 1A (not flown) [Luminary096] -- Descent and Ascent (LM-77773)     ┆
  ┆     ## ======================================================================================    ┆
  ┆     0   ID          B0    FMT_OCT            TBD                                           ^^^^^ ┆
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



    var downListID: Substring

    for lineRange in lineRanges {

        downListID = fileLines[lineRange.lowerBound+1].suffix(6).dropLast()

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

//      let content = fileLines[lineRange.lowerBound+3...lineRange.upperBound].joined(separator: "\n")
        let content = fileLines[lineRange].joined(separator: "\n")

        if let tsvDirectory = fileManager.urls(for: .desktopDirectory,
                                               in: .userDomainMask).first {
            let fileURL = tsvDirectory
                .appendingPathComponent("downlist")
                .appendingPathComponent("tsv")
                .appendingPathComponent("\(fileName)")
                .appendingPathComponent("ddd-\(downListID)-\(fileName).tsv")

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
