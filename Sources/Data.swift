//
//  Data.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on Feb24/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation
import RegexBuilder
#if os(macOS)
import OSLog
#elseif os(Linux)
import Logging
#endif
        
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ .. reads from "*.join" file and writes to "*.data"                                               │
  │╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌│
  │               1DNADR VN +2           # s (  110  )  56 # VN +2,+3                                │
  │               1DNADR VN +4           # s (  112  )  57 # VN +4,+5                                │
  │               1DNADR PIPTIME         # s (  114  )  58 # PIPTIME,+1                              │
  │     #*      → 6DNADR DNTMBUFF                          # SEND SNAPSHOT                           │
  │     #       → DNPTR LMAGSI04         #   (  ---  )     # COMMON DATA                             │
  │               2DNADR OMEGAPD         # c (116,118)  59 # OMEGAPD,OMEGAQD,OMEGARD,GARBAGE         │
  │               3DNADR CADRFLSH        # c (120-124)  61 # CADRFLSH,+1,+2,FAILREG,+1,+2            │
  │               1DNADR RADMODES        # c (  126  )  64 # RADMODES,DAPBOOLS       COMMON DATA     │
  │╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌│
  │                                                                                                  │
  │ .. drops prefixes "# " and "#*" -- they don't contribute data to the output ..                   │
  │                                                                                                  │
  │ .. edits a whole pile of lines with typos and inconsistent usage .. some mission dependent       │
  │                                                                                                  │
  │ .. parse lines to                                                                                │
  │               1DNADR   PIPTIME         # s (  114  )  58 # PIPTIME,+1                            │
  │               instr    oprnd             range             comment                               │
  │                                                                                                  │
  │ .. emitLine(order, range, instr, oprnd, format, comment) to output                               │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

#if os(macOS)
let logger = Logger(subsystem: "com.ramsaycons.PDL", category: "data")
#elseif os(Linux)
let logger = Logger(label: "com.ramsaycons.PDL")
#endif

var order = 0

func dataFile(_ missionName: String, _ fileLines: [String]) -> [String] {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ process the lines of the file to isolate downlists ..                                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    var newLines: [String] = []

    for var line in fileLines {

        if line.isEmpty || ["# ", "#*"].contains(where: line.hasPrefix) { continue }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ new downlink ..                                                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if line.starts(with: "##") { newLines.append(line); order = 0; continue }

        line.replace("SNAPSHOT", with: "")
        line.replace("COMMON DATA", with: "")
        line.replace("SNAPSHOT DATA", with: "")
        line.replace("# FORMERLY PIF", with: "")

        line.replace("DISPLAY TABLES", with: "DSPTAB +0...+11")
        line.replace("DSPTAB TABLES",  with: "DSPTAB +0...+11")

        line.replace("FLAGWRD0 THRU FLAGWRD9", with: "STATE +0...+9")               // Colossus237
        line.replace("FLAGWRDS 10 AND 11", with: "STATE +10...+11")                 // Colossus237

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASES: these usages can be eliminated early ..                                       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        line.replace("CSTEER,+1", with: "CSTEER,GARBAGE")                               // CM-77774
        line.replace("ECSTEER,+1", with: "ECSTEER,GARBAGE")                             // CM-77775

        line.replace("DELV,+1,...+4,+5",    with: "DELV +0...+5")                       // CM-77774
        line.replace("DELVEET3,+1,...+4,+5", with: "DELVEET3 +0...+5")                  // CM-77775
        line.replace("DELVSLV,+1...+4,+5",   with: "DELVSLV +0...+5")                   // CM-77775

        line.replace("LAT(SPL),+1,LNG(SPL),+1", with: "LAT(SPL),+1,LNG(SPL),+1")        // CM-77776
        line.replace("LAT(SPL),LNG(SPL),+1",    with: "LAT(SPL),+1,LNG(SPL),+1")

        line.replace("MARKDOWN,+1...+5,+6,GARBAGE", with: "MARKDOWN,+0...+5,+6,GARBAGE") // MARKTIME STAR 1
        line.replace("MARK2DWN,+1...+5,+6", with: "MARK2DWN,+0...+5,+6,GARBAGE")         // MARKTIME STAR 2

        line.replace("OPTION1,2", with: "OPTION1,OPTION2")
        line.replace("PIPTIME1", with: "PIPTIME")

        line.replace("REFSMMAT,+1,...+10,+11", with: "REFSMMAT +0...+11")

        line.replace("RLS,+1,...+4,+5", with: "RLS +0...+5")                            // CM-77773

        line.replace("RTARG,+1,+2,...+5", with: "RTARG +0...+5")                        // CM-77774
        line.replace("RTARG,+1...+4,+5",  with: "RTARG +0...+5")                        // CM-77775
        line.replace("RTARG,+1...+5",     with: "RTARG +0...+5")

        line.replace("TIME/1",  with: "TIME2,TIME1")
        line.replace("TIME2/1", with: "TIME2,TIME1")

        line.replace("UPBUFF,+1...+10,+11",      with: "UPBUFF +0...+11")               // CM-77776
        line.replace("UPBUFF+0,+1...+10,+11D",   with: "UPBUFF +0...+11")
        line.replace("UPBUFF+12,+13...+18,+19D", with: "UPBUFF +12...+19")
        line.replace("UPBUFF+12,13...+18,19D",   with: "UPBUFF +12...+19")              // CM-77776

        line.replace("VGTIG,...+5",       with: "VGTIGX,VGTIGY,VGTIGZ")
        line.replace("VGTIG,+1,...+4,+5", with: "VGTIGX,VGTIGY,VGTIGZ")
        line.replace("VGTIGX,Y,Z",        with: "VGTIGX,VGTIGY,VGTIGZ")

        line.replace("VGVECT +0...+5", with: "VG VEC X,VG VEC Y,VG VEC Z")
        line.replace("VGVECT+0...+5",  with: "VG VEC X,VG VEC Y,VG VEC Z")

        line.replace("DVOTAL,+1", with: "DVTOTAL,+1")                                   // Skylark048 ###TYPO

        line.replace("APOGEE AND PERIGEE FROM R30   (28-29)", with: "HAPO,HPER")        //###Apr03/25: Manche45R2
        line.replace("PACTOFF, YACTOFF                 (30)", with: "PACTOFF,YACTOFF")  // Skylark048 ###MAR12

        line.replace("CDUXD,CDUXD,CDUZD,GARBAGE", with: "CDUXD,CDUYD,CDUZD,GARBAGE")    // Luminary099 ###TYPO
        line.replace("# FC,+1", with: "# FC,GARBAGE")                                   // Luminary210

        line.replace("TSIGHT,TSIGHT +1", with: "TSIGHT")                                // Luminary210

        line.replace("MKTIME,+1,RM,+1", with: "MKTIME,RM+0,RM+1")                       // Sundance306ish

        line.replace("HAPOX,+1,HPERX,+1", with: "HAPO,+1,HPER,+1")                      // Skylark048, Artemis072

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     → Colossus249 (77776) [Colossus-1A]                                                 APR01/25 ┆
  ┆     → Manche45R2 (77776) [           ]                                                  APR01/25 ┆
  ┆     → Artemis072 (77776) [           ]                                                  APR01/25 ┆
  ┆     →         3DNADR ERRORX                            # ERRORX/Y/Z,THETADX/Y/Z                  ┆
  ┆     →                                                  # 6 single words                          ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if ["Colossus249", "Manche45R2", "Artemis072", "Skylark048"].contains(missionName) {
            line.replace("ERRORX/Y/Z,THETADX/Y/Z",
                   with: "ERRORX,ERRORY,ERRORZ,THETADX,THETADY,THETADZ")
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     → Luminary210 (77776) [           ]                                                 APR01/25 ┆
  ┆     →         2DNADR CHANBKUP                          → CHANBKUP,FAILREG,+1,+2                  ┆
  ┆     →                                                  # 4 single words                          ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if ["Luminary210"].contains(missionName) {
            if line.contains("2DNADR CHANBKUP") {
                line.append("           # CHANBKUP,FAILREG,+1,+2")
            }
        }


        if let match = line.firstMatch(of: long) {
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ match an assembler line and split it into pieces:                                                │
  │                                                                                                  │
  │         2DNADR  CMDAPMOD +2                  #   (034,036) # CMDAPMOD,PREL,QREL,RREL             │
  │         -----+  ----------+                   ------------+  +----------------------             │
  │              |            |                               |  |                                   │
  │              |            oprnd: "CMDAPMOD"               |  comment: "CMDAPMOD,PREL,QREL,RREL"  │
  │              instr: "2DNADR"                              range: "   (034,036) "                 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

            var instr = String(match.1)
            let oprnd = match.2.trimmingCharacters(in: .whitespaces)
            let range = String(match.3)
            let comment = match.4
                .replacingOccurrences(of: "DATA", with: "")             // ← SPECIAL CASE
                .replacingOccurrences(of: "CHANNELS 76(GARBAGE),77", with: "GARBAGE,CHANNEL77")
                .replacingOccurrences(of: "CSI DELTA VELOCITY COMPONENTS", with: "DELVEET1 +0...+5")
                .replacingOccurrences(of: "CDH DELTA VELOCITY COMPONENTS", with: "DELVEET2 +0...+5")
                .replacingOccurrences(of: "CDH AND CSI TIME", with: "TCDH +0...+3")
                .replacingOccurrences(of: "CDH DELTA ALTITUDE", with: "DIFFALT")
                .trimmingCharacters(in: .whitespaces)

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ DNCHAN .. channel downlink ..                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
            if instr == "DNCHAN" {
                if let match = comment.firstMatch(of: chNumb) {         // "CHANNELS «m»,«n»"
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                                              "CHANNELS 13,14"                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    newLines.append(emitLine(order, range, instr,    "CHAN"+match.1, .single, comment))
                    newLines.append(emitLine(order, range, "      ", "CHAN"+match.2, .single, comment))

                } else if let match = comment.firstMatch(of: chWord) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                                              "CHANNELS GARBAGE,CHANNEL77"        ┆
  ┆                                                              "CHANNELS 76(GARBAGE),77"           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    newLines.append(emitLine(order, range, instr, "GARBAGE", .single, comment))
                    newLines.append(emitLine(order, range, "      ", "CHAN"+match.1, .single, comment))

                }

                continue
            }

            if oprnd == "SPARE" {
                newLines.append(emitLine(order, range, instr, oprnd, .double, comment))
            }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ split the comment field into bits ..                                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let commentBits = splitComment(oprnd, comment)

            if (oprnd.starts(with: "SVMRKDAT")) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL                                                                                      ┆
  ┆     SVMRKDAT is three 6DNADR items in the downlist                                               ┆
  ┆                                                                                                  ┆
  ┆         6DNADR SVMRKDAT                     #   (034-044) # SVMRKDAT+0...+11                     ┆
  ┆         6DNADR SVMRKDAT +12D                #   (046-056) # SVMRKDAT+12...+23                    ┆
  ┆         6DNADR SVMRKDAT +24D                #   (058-068) # SVMRKDAT+24...+35                    ┆
  ┆                                                                                                  ┆
  ┆     but is actually five sets of one structure                                                   ┆
  ┆                                                                                                  ┆
  ┆         { 34, "SVMRKDAT=",    B28, FMT_DP  },   // 1st mark                                      ┆
  ┆         { 36, "SVMRKDAT+2=",  360, FMT_USP },                                                    ┆
  ┆         { 37, "SVMRKDAT+3=",  360, FMT_USP },                                                    ┆
  ┆         { 38, "SVMRKDAT+4=",  360, FMT_USP },                                                    ┆
  ┆         { 39, "SVMRKDAT+5=",   45, FMT_SP, &FormatOTRUNNION },                                   ┆
  ┆         { 40, "SVMRKDAT+6=",  360, FMT_USP },                                                    ┆
  ┆          . . . . . .                                                                             ┆
  ┆         { 62, "SVMRKDAT+28=", B28, FMT_DP  },   // 5th mark                                      ┆
  ┆         { 64, "SVMRKDAT+30=", 360, FMT_USP },                                                    ┆
  ┆         { 65, "SVMRKDAT+31=", 360, FMT_USP },                                                    ┆
  ┆         { 66, "SVMRKDAT+32=", 360, FMT_USP },                                                    ┆
  ┆         { 67, "SVMRKDAT+33=",  45, FMT_SP, &FormatOTRUNNION },                                   ┆
  ┆         { 68, "SVMRKDAT+34=", 360, FMT_USP },                                                    ┆
  ┆         { 69, "GARBAGE",        1, FMT_OCT },                                             MAR215 ┆
  ┆                                                                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                switch commentBits[0] {
                    case "SVMRKDAT+0":
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+0", .double))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+2", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+3", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+4", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+5", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+6", .single))

                        newLines.append(emitLine(order, "", "", "SVMRKDAT+7", .double))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+9", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+10", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+11", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+12", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+13", .single))

                        newLines.append(emitLine(order, "", "", "SVMRKDAT+14", .double))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+16", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+17", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+18", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+19", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+20", .single))

                        newLines.append(emitLine(order, "", "", "SVMRKDAT+21", .double))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+23", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+24", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+25", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+26", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+27", .single))

                        newLines.append(emitLine(order, "", "", "SVMRKDAT+28", .double))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+30", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+31", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+32", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+33", .single))
                        newLines.append(emitLine(order, "", "", "SVMRKDAT+34", .single))

                        newLines.append(emitLine(order, "", "", "GARBAGE", .single))

                    default: break
                }

                continue
            }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     process nDNADR (n words in downlist)                                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let downCount = Int(String(instr.first!))!

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ .. a 1DNADR with a comment ending ",+1" will probably be a "double" .. deal with it now ..       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if instr == "1DNADR" && !comment.contains("/") && comment.hasSuffix(",+1") {
                let shortOperand = upToPlus(oprnd)
                if forceSingle.contains(shortOperand) {
                    newLines.append(emitLine(order, range, instr,
                                             shortOperand, .single, comment))
                    newLines.append(emitLine(order, range, instr,
                                             shortOperand + "+1", .single, comment))
                } else {
                    newLines.append(emitLine(order, range, instr,
                                             shortOperand, .double, comment))
                }
                continue
            }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL                                                                                      ┆
  ┆                                                                                                  ┆
  ┆ .. a 2DNADR with three variables -- only happens once (one doubles and two singles)              ┆
  ┆          2DNADR MKTIME       #   (040,042) # MKTIME,RM+0,RM+1"                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if downCount == 2 && commentBits.count == 3 {

                newLines.append(emitLine(order, "", "", String(commentBits[0]), .double, comment))
                newLines.append(emitLine(order, "", "", String("RR_DIST"), .single, comment))
                newLines.append(emitLine(order, "", "", String("RR_RATE"), .single, comment))

                continue
            }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL                                                                                      ┆
  ┆                                                                                                  ┆
  ┆ .. a 6DNADR with eight variables -- only happens once (four singles and four doubles)            ┆
  ┆     S68  6DNADR COMPNUMB     #   (034-044) # COMPNUMB,UPOLDMOD,UPVERB,UPCOUNT,UPBUFF+0...+7      ┆
  ┆     S68  6DNADR COMPNUMB     # c (034-044) # COMPNUMB,UPOLDMOD,UPVERB,UPCOUNT,UPBUFF+0...+7      ┆
  ┆     S68  6DNADR COMPNUMB     # c (134-144) # COMPNUMB,UPOLDMOD,UPVERB,UPCOUNT,UPBUFF+0...+7      ┆
  ┆                                                                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if downCount == 6 && commentBits.count == 8 {

                for i in 0...3 {
                    newLines.append(emitLine(order, range, instr,
                                             String(commentBits[i]),
                                             .single, comment))
                }
                for i in 4...7 {
                    newLines.append(emitLine(order, range, instr,
                                             String(commentBits[i]),
                                             .double, comment))
                }
                continue
            }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL                                                                                      ┆
  ┆                                                                                                  ┆
  ┆ .. a 4DNADR with eight variables -- only happens once (three doubles and two singles)            ┆
  ┆     S46  4DNADR MARKDOWN     #   (038-044) # MARKDOWN,+0...+5,+6,GARBAGE                         ┆
  ┆                                                                                                  ┆
  ┆ .. a 4DNADR with eight variables -- only happens once (one double and six singles)               ┆
  ┆     S46  4DNADR AGSBUFF +7   #   (026-032) # AGSBUFF+7...+13D,GARBAGE                            ┆
  ┆                                                                                                  ┆
  ┆ .. a 4DNADR with eight variables -- only happens once (eight singles)                            ┆
  ┆     S46  4DNADR UPBUFF +12D  #   (052-058) # UPBUFF +12...+19                                    ┆
  ┆                                                                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if downCount == 4 && commentBits.count == 8 {

                if (oprnd.starts(with: "MARKDOWN") || oprnd.starts(with: "MARK2DWN")) {
                    newLines.append(emitLine(order, range, instr, String(commentBits[0]), .double))
                    for i in 2...7 {
                        newLines.append(emitLine(order, range, instr,
                                                 String(commentBits[i]),
                                                 .single, comment)) }
                    continue
                }

                if (oprnd.starts(with: "AGSBUFF")) {
                    for i in stride(from: 0, to: 5, by: 2) {
                        newLines.append(emitLine(order, range, instr,
                                                 String(commentBits[i]),
                                                 .double, comment)) }
                    for i in 6...7 {
                        newLines.append(emitLine(order, range, instr,
                                                 String(commentBits[i]),
                                                 .single, comment)) }
                    continue
                }
            }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL                                                                                      ┆
  ┆                                                                                                  ┆
  ┆ .. a 4DNADR with seven variables -- only happens once (one doubles and six singles)              ┆
  ┆     S47  4DNADR MARKDOWN     #   (046-052) # MARKDOWN,+1...+5,+6,RM                              ┆
  ┆     S47  4DNADR MARKDOWN     #   (046-052) # MARKTIME(DP),YCDU,SCDU,ZCDU,TCDU,XCDU,RM            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if downCount == 4 && commentBits.count == 7 {

                newLines.append(emitLine(order, range, instr,
                                         String(commentBits[0].replacing("(DP)", with: "")),
                                         .double, comment))
                for i in 1...6 {
                    newLines.append(emitLine(order, range, instr,
                                             String(commentBits[i]), .single, comment)) }
                continue
            }

            if downCount == commentBits.count/2 {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ May be SINGLE                                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

                let shortOperand = upToPlus(oprnd)
                if forceDouble.contains(shortOperand) {
                    let everyOtherBit = commentBits.enumerated()
                        .filter { $0.offset % 2 == 0 }.map { $0.element }

                    for bit in everyOtherBit {
                        newLines.append(emitLine(order, range, instr,
                                                 String(bit), .double, comment))
                        instr = "      "
                    }

                } else {

                    for bit in commentBits {
                        newLines.append(emitLine(order, range, instr,
                                                 String(bit), .single, comment))
                        instr = "      "
                    }
                }

                continue
            }

            if downCount == commentBits.count {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ DOUBLE                                                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                for bit in commentBits {
                    newLines.append(emitLine(order, range, instr,
                                             String(bit),
                                             .double, comment))
                    instr = "      "
                }

                continue
            }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ DOUBLE                                                                                           ┆
  ┆                                                                                                  ┆
  ┆ nDNADR : n = 1                                                                                   ┆
  ┆ ["A","B","C","D","E","F"]                                                                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            for i in 1...downCount {
                newLines.append(emitLine(order, range, i == 1 ? instr : "      ",
                                         commentBits.count < downCount ? oprnd : String(commentBits[i-1]),
                                         .double, comment))
                continue
            }
        } else if let match = line.firstMatch(of: noComment) {
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ failed to match the assembler line WITH comment .. check for a line WITHOUT comment ..           │
  │                                                                                                  │
  │ "       2DNADR  CMDAPMOD                     #   (034,036)                                       │
  │         -----+  -------+                      ------------+                                      │
  │              |         |                                  |                                      │
  │              |         label: "CMDAPMOD"                  |                                      │
  │              |                                            |                                      │
  │              opCode: "2DNADR"                             range: "   (034,036) "                 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

            let opCode = String(match.1)
            let label = match.2.trimmingCharacters(in: .whitespaces)
            let range = String(match.3)

            newLines.append(emitLine(order, range, opCode, label, .double, ""))
            continue
        } else {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ if in doubt, just append the line ..                                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            newLines.append(line)
        }
    }

    return newLines
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ takes "R-OTHER" (label) and "R-OTHER +0,+1" (comment) and returns and array of new labels based  │
  │ on figuring out, as best as possible, offsets and single/double precision ..                     │
  │                                                                                                  │
  │ .. if (label) == first substring of (comment)                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
fileprivate func splitComment(_ label: String, _ comment: String) -> [Substring] {
    var result = [Substring]()
    if comment.isEmpty { return result }

    if comment.contains("+") {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ comment text contains a "+"                                                                      ┆
  ┆                                                            split on "," and trim each sub-string ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var bits = comment.split(separator: ",")
            .map { $0.replacingOccurrences(of: " ", with: "") }

        if bits.count == 4 {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ the parsing is tricky since characters are missing                                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if bits[1...3] == ["+1", "...+4", "+5"] { bits = [bits[0], "+1...+5"] }
            if bits[1...3] == ["+1", "+2", "...+5"] { bits = [bits[0], "+1...+5"] }
            if bits[1...3] == ["+1", "...+10", "+11"] { bits = [bits[0], "+1...+11"] }
        }

        if bits.count == 3 {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ coagulate run-on uses "1...4,5" ← "1...5"                                                        ┆
  ┆     ### could be more clever and deal with "D" and missing "+"                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if bits[1...2] == ["+1...+4", "+5"] { bits = [bits[0], "+1...+5"] }
            if bits[1...2] == ["+1...+5", "+6"] { bits = [bits[0], "+1...+6"] }
            if bits[1...2] == ["+1...+10", "+11"] { bits = [bits[0], "+1...+11"] }
            if bits[1...2] == ["+1...+10", "+11D"] { bits = [bits[0], "+1...+11"] }
            if bits[1...2] == ["+13...+18", "+19D"] { bits = [bits[0], "+13...+19"] }
            if bits[1...2] == ["13...+18", "19D"] { bits = [bits[0], "+13...+19"] }

            if bits[1].contains("/") {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ "A","B/C","D" → "A","B" [ the "C","D" was an alternate]                                          ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                let twoBits = bits[1].split(separator: "/")     // ["B","C"]
                bits[1] = String(twoBits[0])
                bits = bits.dropLast()
            }
        }

        if bits.count == 2 {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ "A","...5" → "A","+0...+5"                                                                       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if bits[1] == "...+5" { bits = [bits[0], "+0...+5"] }

            if bits[0] == "YNBSAV+0...+5" && bits[1] == "ZNBSAV+0...+5" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ "A+0...+5","B+0...+5" → "A","+0...+5","B","+0...+5"                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                bits = ["YNBSAV", "+0...+5", "ZNBSAV", "+0...+5"]
            }
        }


        switch bits.count {
            case 1:
                if let match = bits[0].firstMatch(of: code) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["A+m...+n"] → ["A", m, n] → ["A+m", "A+m", .. "A+n"]                                        ┆
  ┆                                                                                                  ┆
  ┆     ["GSAV+0...+5"] → ["GSAV", 0, 5] → ["GSAV+0", "GSAV+1", .., "GSAV+4", "GSAV+5"]              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let alpha = Int(String(match.2))!
                    let omega = Int(String(match.3))!
                    for i in alpha...omega { result.append("\(match.1)+\(i)") }
                    return result

                }

                logger.log("×1 \(bits)")

            case 2:
                if !bits[0].contains("+") && bits[1].contains("...") {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### SPECIAL CASE (ONLY ONE): "VGTIG,...+5" → "VGTIG,+1...+5"                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    if bits[1] == "...+5" { bits[1] = "+1...+5" }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["A", "+m...+n"] → ["A", m, n] → ["A+m", "A+m", .. "A+n"                                     ┆
  ┆                                                                                                  ┆
  ┆     ["DELV", "+1...+5"] → ["DELV+1", "DELV+2", "DELV+3", "DELV+4", "DELV+5"]                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    if let match = bits[1].firstMatch(of: dots) {
                        let alpha = Int(String(match.1))!
                        let omega = Int(String(match.2))!
                        for i in alpha...omega { result.append("\(bits[0])+\(i)") }
                        return result

                    } else {
                        logger.log("×2a \(bits)")
                    }

                } else if let matchA = bits[0].firstMatch(of: plus),
                          let matchB = bits[1].firstMatch(of: numb) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["A+m", "+n"] → ["A", m, n] → ["A+m", .., "A+n"]                                             ┆
  ┆                                                                                                  ┆
  ┆     ["DELV+4", "+5"] → ["DELV+4", "DELV+5"]                                                      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let label = String(matchA.1)
                    let alpha = Int(String(matchA.2))!
                    let omega = Int(String(matchB.1))!

                    for i in alpha...omega { result.append("\(label)+\(i)") }

                    return result

                } else if bits[1].starts(with: "+") && bits[1].last != "D" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["A", "+m"] → ["A", m] → ["A+0", "A+1", .. "A+m"]                                            ┆
  ┆                                                                                                  ┆
  ┆     ["AGSK", "+1"] → ["AGSK+0", "AGSK+1"]                                                        ┆
  ┆     ["TTF/8", "+1"] → ["TTF/8+0", "TTF/8+1"]                                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let offset = Int(bits[1].dropFirst())!
                    if offset == 1 {
                        result.append("\(bits[0])+\(offset-1)")         // "AGSK+0"
                        result.append("\(bits[0])+\(offset)")
                    } else {
                        logger.log("×2 (+\(offset)) \(bits)")           // doesn't happen
                    }
                    return result

                } else  {

                    for bit in bits {
                        if let match = bit.firstMatch(of: code) {           // "WORD␠+m...+n"
                            let alpha = Int(String(match.2))!
                            let omega = Int(String(match.3))!
                            for i in alpha...omega { result.append("\(match.1)+\(i)") }
                        } else if let match = bit.firstMatch(of: plus) {    // "WORD␠+m"
                            result.append("\(match.1)+\(match.2)")
                        } else {
                            result.append("\(bit)")
                        }
                    }
                    return result

                }

                logger.log("×2z \(bits)")

            case 3:
                for bit in bits { result.append(Substring(bit)) }

                return result

            case 4:
                if bits[1] == "+1" && bits[3] == "+1" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAME1", "+1", "NAME2", "+1"] → ["NAME1", "NAME2"]                                  doubles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    result.append("\(bits[0])")                     // "NAME1"
                    result.append("\(bits[2])")                     // "NAME2"
                    return result
                } else if bits[2] == "+1" && bits[3] == "+2" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAME1", "NAME2", "+1", "+2"] → ["NAME1", "NAME2+0", "NAME2+1", "NAME2+2"]          singles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    result.append("\(bits[0])")                     // "NAME1"
                    bits[1].replace("+0", with: "")
                    result.append("\(bits[1])+0")                   // "NAME2+0"
                    result.append("\(bits[1])+1")                   // "NAME2+1"
                    result.append("\(bits[1])+2")                   // "NAME2+2"
                    return result
                } else if bits[1] == "+1" && bits[2] == "+2" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAME1", "+1", "+2", "NAME2] → ["NAME1+0", "NAME1+1", "NAME1+2", "NAME2"]           singles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    result.append("\(bits[0])+0")                   // "NAME1+0"
                    result.append("\(bits[0])+1")                   // "NAME1+1"
                    result.append("\(bits[0])+2")                   // "NAME1+2"
                    result.append("\(bits[3])")                     // "NAME2"
                    return result
                } else if let match1 = bits[1].firstMatch(of: dots),
                          let match2 = bits[3].firstMatch(of: dots) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["A", "+1...+5", "B", "+1...+5"] → ["A+0", .., "A+5", "B+1", .., "B+5", ..]                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    var alpha = Int(String(match1.1))!
                    var omega = Int(String(match1.2))!
                    for i in alpha...omega { result.append("\(bits[0])+\(i)") }

                    alpha = Int(String(match2.1))!
                    omega = Int(String(match2.2))!
                    for i in alpha...omega { result.append("\(bits[2])+\(i)") }

                    return result

                } else if let match = bits[1].firstMatch(of: dots) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAME1", "+1...+5", "+6", "NAME2] → ["NAME1+0", "NAME1+1", .., "NAME1+6", "NAME2"]  singles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let alpha = Int(String(match.1))!
                    let omega = Int(String(match.2))!
                    for i in alpha...omega { result.append("\(bits[0])+\(i)") }
                    result.append("\(bits[0])+\(omega+1)")
                    result.append("\(bits[3])")                 // "NAME2"
                    return result

                }

                if let matchA = bits[0].firstMatch(of: plus),
                   let matchB = bits[1].firstMatch(of: numb),
                   let matchC = bits[2].firstMatch(of: plus),
                   let matchD = bits[3].firstMatch(of: numb) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAMEA+2", "+3", "NAMEB+2", "+3"] → ["NAMEA", "NAMEB"]                              doubles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    var label = String(matchA.1)
                    var alpha = Int(String(matchA.2))!
                    var omega = Int(String(matchB.1))!

                    if omega-alpha == 1 {
                        result.append("\(label)+\(alpha)")
                    } else {
                        for i in alpha...omega { result.append("\(label)+\(i)") }
                    }

                    label = String(matchC.1)
                    alpha = Int(String(matchC.2))!
                    omega = Int(String(matchD.1))!

                    if omega-alpha == 1 {
                        result.append("\(label)+\(alpha)")
                    } else {
                        for i in alpha...omega { result.append("\(label)+\(i)") }
                    }

                    return result
                }

                if !bits[0].contains("+") && bits[1].contains("...") &&
                   !bits[2].contains("+") && bits[3].contains("...") {
                    if bits[1] == "...+5" { bits[1] = "+0...+5" }               // ← SPECIAL CASE
                    if bits[3] == "...+5" { bits[3] = "+0...+5" }               // ← SPECIAL CASE
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NA", "...+5", "NB", "...+5"] → ["NA+0", .., "NA+3", ""NB+0", .., "NB+3"]           singles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    if let match = bits[1].firstMatch(of: dots) {
                        let alpha = Int(String(match.1))!
                        let omega = Int(String(match.2))!
                        for i in alpha...omega { result.append("\(bits[0])+\(i)") }
                    }

                    if let match = bits[3].firstMatch(of: dots) {
                        let alpha = Int(String(match.1))!
                        let omega = Int(String(match.2))!
                        for i in alpha...omega { result.append("\(bits[2])+\(i)") }
                    }

                    return result

                }

                logger.log("×4  \(bits)")

            case 5:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["COMPNUMB", "UPOLDMOD", "UPVERB", "UPCOUNT", "UPBUFF+0...+7"]                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                for i in 0...3 { result.append("\(bits[i])") }

                if let match = bits[4].firstMatch(of: code) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ ### this is tricky .. the first four variables are single precision occupying two words, so the  ┆
  ┆     remaining eight ("UPBUFF+0...+7") have to be double precision, hence:                        ┆
  ┆                              "UPBUFF+0...+7" → ["UPBUFF+0", "UPBUFF+2", "UPBUFF+4", "UPBUFF+6"]  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let alpha = Int(String(match.2))!
                    let omega = Int(String(match.3))!
                    for i in stride(from: alpha, through: omega, by: 2) { result.append("\(match.1)+\(i)") }
                    return result
                }

                logger.log("×5  \(bits)")

            case 6:
                if bits[1] == "+1" && bits[3] == "+1" && bits[5] == "+1" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["NAME1", "+1", "NAME2", "+1", "NAME3", "+1"] → ["NAME1", "NAME2, "NAME3"]           doubles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    result.append("\(bits[0])")                     // "NAME1"
                    result.append("\(bits[2])")                     // "NAME2"
                    result.append("\(bits[4])")                     // "NAME2"
                    return result
                } else if bits[1] == "+1" && bits[2] == "+2" &&
                          bits[4] == "+1" && bits[5] == "+2" {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     ["N1", "+1", "+2", "N2", "+1", "+2"] → ["N1+0", .., "N1+2", "N2+0", .., "N2+2"]      singles ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    result.append("\(bits[0])+0")                   // "N1+0"
                    result.append("\(bits[0])+1")                   // "N1+1"
                    result.append("\(bits[0])+2")                   // "N1+2"
                    result.append("\(bits[3])+0")                   // "N2+0"
                    result.append("\(bits[3])+1")                   // "N2+1"
                    result.append("\(bits[3])+2")                   // "N2+2"

                    return result
                }

                logger.log("×6  \(bits)")

            case 7:
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "MARKTIME(DP),YCDU,SCDU,ZCDU,TCDU,XCDU,RM"                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                result.append(Substring(bits[0].replacing("(DP)", with: "")))
                for i in 1..<bits.count {
                    result.append(Substring(bits[i]))
                }

            default:
                logger.log("×\(bits.count)  \(bits)")

        }

    } else {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ comment text contains a "," and no "+"                                                           ┆
  ┆                                                                just split them (nothing special) ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if comment.contains(",") {
            return comment.split(separator: ",")
                .map { Substring($0.trimmingCharacters(in: .whitespaces)) }
        }

        if let match = comment.wholeMatch(of: Regex { Capture { OneOrMore(.word) } }) {
            return [match.1]
        }

        if comment.contains(" ") {
            return [Substring(label)]
        }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ comment text contains no "," and no "+" (ERROR)                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

        logger.log("-  \(#function): '\(comment)'")

    }

    return []
}

enum Precision {
    case single
    case double
    case ignore
}

fileprivate func emitLine(_ ord: Int = 999,
                          _ ran: String = "",
                          _ opc: String,
                          _ adr: String = "",
                          _ pre: Precision = .ignore,
                          _ com: String = "") -> String {

    order += (pre == .double ? 2 : 1)

    return """
        \(skipLine(ord) ? "\n" : "")\(String(format: "%d", ord))\t\
        \(adr)\t\
        \(pre == .double ? "double" : "single") 
        """

    func skipLine(_ ord: Int) -> Bool { [2,16,58,66,78,34,100,102,116,128,164,180,188].contains(ord) }
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ REGEXs                                                                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "^      2DNADR CMDAPMOD                     #   (034,036) # CMDAPMOD,PREL,QREL,RREL"         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
fileprivate let long = Regex {
    Anchor.startOfLine
    OneOrMore(.whitespace)
    Capture { OneOrMore(.word) }                                    // "2DNADR"
    OneOrMore(.whitespace)
    Capture { OneOrMore(CharacterClass(.word, .anyOf(" +-(/)"))) }  // "CMDAPMOD"
    "#"
    Capture { OneOrMore(.anyGraphemeCluster) }                      // "   (034,036) "
    "#"
    Capture { OneOrMore(CharacterClass(.word, .anyOf("()/.,+- "))) } // "CMDAPMOD,PREL,QREL,RREL"
    Optionally {
        "("
        OneOrMore(.anyGraphemeCluster)
        ")"
    }
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "^      2DNADR CMDAPMOD                     #   (034,036)                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
fileprivate let noComment = Regex {
    Anchor.startOfLine
    OneOrMore(.whitespace)
    Capture { OneOrMore(.word) }                                    // "2DNADR"
    OneOrMore(.whitespace)
    Capture { OneOrMore(CharacterClass(.word, .anyOf(" +-(/)"))) }  // "CMDAPMOD"
    "#"
    Capture { OneOrMore(.anyGraphemeCluster) }                      // "   (034,036) "
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "WORD␠+m...+n" (where "␠" is an optional " ")                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
fileprivate let code = Regex {
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/-_()"))) }
    Optionally(" ")
    dots
    Optionally { OneOrMore(.word) }
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "WORD␠+m" (for example "AGSBUFF+0" -- where "␠" is an optional " ")                          ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
fileprivate let plus = Regex {
    Capture { OneOrMore(CharacterClass(.word, .anyOf("/-_()"))) }
    Optionally(" ")
    "+"
    Capture { OneOrMore(.digit) }
    Optionally("D")
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "+m...+n"                                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
fileprivate let dots = Regex {
    numb
    "..."
    numb
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "+m"                                                                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
fileprivate let numb = Regex {
    Optionally("+")
    Capture { OneOrMore(.digit) }
    Optionally("D")
}

fileprivate func getPair(_ s: Substring) -> (Int, Int)? {
    guard let match = s.firstMatch(of: dots) else { return nil }
    return (Int(String(match.1))!, Int(String(match.2))!)
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "CHANNELS␠m,␠n"                                                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
fileprivate let chNumb = Regex {
    "CHANNEL"
    Optionally("S")
    Optionally(.whitespace)
    Capture { OneOrMore(.digit) }
    Optionally(.whitespace)
    ","
    Optionally(.whitespace)
    Capture { OneOrMore(.digit) }
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     "CHANNELS GARBAGE,CHANNEL77"                                                                 ┆
  ┆     "CHANNELS 76(GARBAGE),77"                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
let chWord = Regex {
    "GARBAGE"
    ","
    Optionally("CHANNEL")
    Capture { OneOrMore(.digit) }
}

fileprivate func upToPlus(_ s: String) -> String {
    let upToPlus = Regex {
        Capture { OneOrMore(CharacterClass(.word, .anyOf("/-_"))) }
        Optionally { .anyGraphemeCluster }
    }

    if let match = s.firstMatch(of: upToPlus) { return String(match.1) } else { return s }
}
