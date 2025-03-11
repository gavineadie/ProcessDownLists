//
//  Xtra.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 3/5/25.
//

import Foundation
import RegexBuilder

func xtraFile(_ missionName: String, _ fileLines: [String]) -> [String] {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ process the lines of the file and append extra columns ..                                        ┆
  ┆                                                                                                  ┆
  ┆     0	ID          : B0     FMT_OCT                                                             ┆
  ┆     1	SYNC        : B0     FMT_OCT                                                             ┆
  ┆     2	R-OTHER+0   : B29    FMT_DP                                                              ┆
  ┆     4	R-OTHER+2   : B29    FMT_DP                                                              ┆
  ┆     6	R-OTHER+4   : B29    FMT_DP                                                              ┆
  ┆     8	V-OTHER+0   : B7     FMT_DP                                                              ┆
  ┆     10	V-OTHER+2   : B7     FMT_DP                                                              ┆
  ┆     12	V-OTHER+4   : B7     FMT_DP                                                              ┆
  ┆     14	T-OTHER+0   : B28    FMT_DP                                                              ┆
  ┆     16	DNRRANGE    : B28    FMT_DP                                                              ┆
  ┆     17	DNRRDOT     : B28    FMT_DP                                                              ┆

    also change labels to GSOP names
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    var newLines: [String] = []

    for line in fileLines {

        if line.starts(with: "##") { newLines.append(line); order = 0; continue }

        var columns = line.split(separator: "\t")
        guard columns.count == 3 else { fatalError("too many columns in \(line)") }

        if columns[0] == "2" {
            newLines.append("100\tTIME\tB28\tFMT_DP\t\tTBD")
        }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ corrections ..                                                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        columns[1].replace("+0", with: "")

        if ["SPARE", "GARBAGE"].contains(columns[1]) {
            let newLine = "# offset \(columns[0]) is unused"
            newLines.append(newLine)
            continue
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ GSOP substitutes ..                                                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
//        let gsopName = lookupGsopNames[columns[1]] ?? columns[1]
//        let tabLine = "\(columns[0])\t\(gsopName): \(getLookup(columns[1]))"


//      let txtLine = "\(columns[0])\t\(columns[1].padTo12()): \(getLookup(columns[1]))"
        let tabLine = "\(columns[0])\t\(columns[1]): \(getLookup(columns[1]))"
            .replacing(Regex {
                ZeroOrMore(.whitespace)
                ":"
                ZeroOrMore(.whitespace)
            }, with: "\t")

//        newLines.append(newLine)
        newLines.append(tabLine)
    }

    return newLines
}

fileprivate func getLookup(_ key: Substring) -> String {

    for (k, v) in lookupScaleFormatUnits {
        if key == k { return v }
    }

    for (k, v) in lookupScaleFormatUnits {
        if key.starts(with: k) { return v }
    }

    return "B0   : FMT_OCT  : FormatUnknown       : TBD"
}

let lookupScaleFormatUnits = [
    "8NN"           : "B0   : FMT_DEC  :                     : TBD",
    "ADOT"          : "450  : FMT_DP   : FormatAdotsOrOga    : TBD",
    "AGSK"          : "B28  : FMT_DP   :                     : TBD",
    "AIG"           : "360  : FMT_SP   :                     : TBD",
    "AK"            : "180  : FMT_SP   :                     : TBD",
    "ALFA/180"      : "180  : FMT_SP   :                     : TBD",
    "ALPHA"         : "90   : FMT_SP   :                     : TBD",
    "ALT"           : "B29  : FMT_DP   :                     : TBD",
    "AMG"           : "360  : FMT_SP   :                     : TBD",
    "AOG"           : "360  : FMT_SP   :                     : TBD",
    "AOTCODE"       : "B0   : FMT_OCT  :                     : TBD",
    "AT"            : "B9   : FMT_DP   :                     : TBD",
    "BEST"          : "6    : FMT_DEC  :                     : TBD",
    "BETA/180"      : "180  : FMT_SP   :                     : TBD",
    "C31FLWRD"      : "B0   : FMT_OCT  :                     : TBD",
    "CADRFLSH"      : "B0   : FMT_OCT  :                     : TBD",
    "CDUS"          : "360  : FMT_SP   :                     : TBD",
    "CDUT"          : "B0   : FMT_OCT  :                     : TBD",
    "CDUX"          : "360  : FMT_SP   :                     : °",
    "CDUY"          : "360  : FMT_SP   :                     : °",
    "CDUZ"          : "360  : FMT_SP   :                     : °",
    "CENTANG"       : "360  : FMT_DP   :                     : TBD",
    "CHAN"          : "B0   : FMT_OCT  :                     : TBD",
    "CM EPOCH"      : "B18  : FMT_DP   : FormatEpoch         : TBD",
    "CM X POS"      : "B25  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "CM X VEL"      : "B15  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "CM Y POS"      : "B25  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "CM Y VEL"      : "B15  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "CM Z POS"      : "B25  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "CM Z VEL"      : "B15  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "CMDAPMOD"      : "B0   : FMT_OCT  :                     : TBD",
    "COMPNUMB"      : "B0   : FMT_OCT  :                     : TBD",
    "CSMMASS"       : "B16  : FMT_SP   :                     : Kg",
    "CSTEER"        : "4    : FMT_SP   :                     : TBD",
    "DAPBOOLS"      : "B0   : FMT_OCT  :                     : TBD",
    "DAPDATR"       : "B0   : FMT_OCT  :                     : TBD",
    "DELLT4"        : "B28  : FMT_DP   :                     : TBD",
    "DELTAH"        : "B24  : FMT_DP   :                     : TBD",
    "DELTAR"        : "360  : FMT_DP   :                     : TBD",
    "RSP-RREC"      : "360  : FMT_DP   :                     : TBD",        // == DELTAR
    "DELV"          : "B14  : FMT_DP   : FormatDELV          : TBD",
    "DELVEET"       : "B7   : FMT_DP   :                     : TBD",
    "DELVSLV"       : "B7   : FMT_DP   :                     : TBD",
    "DELVTPF"       : "B7   : FMT_DP   :                     : TBD",
    "DIFFALT"       : "B29  : FMT_DP   :                     : TBD",
    "DNLRALT"       : "B27  : FMT_SP   : FormatLrRange       : TBD",
    "DNLRVELX"      : "B27  : FMT_SP   : FormatLrVx          : TBD", 
    "DNLRVELY"      : "B27  : FMT_SP   : FormatLrVy          : TBD", 
    "DNLRVELZ"      : "B27  : FMT_SP   : FormatLrVz          : TBD", 
    "DNRRANGE"      : "B0   : FMT_SP   : FormatRrRange       : TBD",
    "DNRRDOT"       : "B0   : FMT_SP   : FormatRrRangeRate   : TBD",
    "DSPTAB"        : "B0   : FMT_2OCT :                     : TBD",
    "ECSTEER"       : "4    : FMT_SP   :                     : TBD",
    "ELEV"          : "360  : FMT_DP   :                     : TBD",
    "ERROR"         : "180  : FMT_SP   :                     : TBD",        // X, Y, Z
    "FAILREG"       : "B0   : FMT_OCT  :                     : TBD",
    "FC"            : "B14  : FMT_SP   : FormatGtc           : TBD",
    "GAMMAEI"       : "360  : FMT_DP   :                     : TBD",
    "GSAV"          : "2    : FMT_DP   :                     : TBD",
    "HAPO"          : "B29  : FMT_DP   :                     : TBD",
    "HMEAS"         : "B28  : FMT_DP   : FormatHMEAS         : TBD",
    "HOLDFLAG"      : "B0   : FMT_DEC  :                     : TBD",
    "HPER"          : "B29  : FMT_DP   :                     : TBD",
    "ID"            : "B0   : FMT_OCT  :                     : TBD",
    "IGC"           : "360  : FMT_DP   :                     : TBD",
    "IMODES"        : "B0   : FMT_OCT  :                     : TBD",
    "L/D1"          : "B0   : FMT_DP   : FormatHalfDP        : TBD",
    "LAND"          : "B24  : FMT_DP   :                     : TBD",
    "LANDMARK"      : "B0   : FMT_OCT  :                     : TBD",
    "LASTXCMD"      : "B0   : FMT_OCT  :                     : TBD",
    "LASTYCMD"      : "B0   : FMT_OCT  :                     : TBD",
    "LAT(SPL)"      : "360  : FMT_DP   :                     : TBD",
    "LNG(SPL)"      : "360  : FMT_DP   :                     : TBD",
    "LATANG"        : "4    : FMT_DP   :                     : TBD",
    "LAUNCHAZ"      : "360  : FMT_DP   :                     : TBD",
    "LEMMASS"       : "B16  : FMT_SP   :                     : Kg",
    "LM EPOCH"      : "B18  : FMT_DP   : FormatEpoch         : TBD",
    "LM X POS"      : "B25  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "LM X VEL"      : "B15  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "LM Y POS"      : "B25  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "LM Y VEL"      : "B15  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "LM Z POS"      : "B25  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "LM Z VEL"      : "B15  : FMT_SP   : FormatEarthOrMoonSP : TBD",
    "LAT"           : "360  : FMT_DP   :                     : TBD",
    "LONG"          : "360  : FMT_DP   :                     : TBD",
    "LRVTIMDL"      : "B28  : FMT_DP   :                     : TBD",
    "LRXCDUDL"      : "360  : FMT_SP   :                     : TBD",
    "LRYCDUDL"      : "360  : FMT_SP   :                     : TBD",
    "LRZCDUDL"      : "360  : FMT_SP   :                     : TBD",
    "MARK2DWN"      : "B28  : FMT_DP   :                     : TBD",        //###
    "MARK2DWN+2"    : "360  : FMT_USP  :                     : TBD",
    "MARK2DWN+3"    : "360  : FMT_USP  :                     : TBD",
    "MARK2DWN+4"    : "360  : FMT_USP  :                     : TBD",
    "MARK2DWN+5"    : "360  : FMT_USP  :                     : TBD",
    "MARK2DWN+6"    : "45   : FMT_SP   : FormatOTRUNNION     : TBD",
    "MARKDOWN"      : "B28  : FMT_DP   :                     : TBD",        //###
    "MARKDOWN+2"    : "360  : FMT_USP  :                     : TBD",
    "MARKDOWN+3"    : "360  : FMT_USP  :                     : TBD",
    "MARKDOWN+4"    : "360  : FMT_USP  :                     : TBD",
    "MARKDOWN+5"    : "360  : FMT_USP  :                     : TBD",
    "MARKDOWN+6"    : "45   : FMT_SP   : FormatOTRUNNION     : TBD",
    "MARKTIME"      : "B28  : FMT_DP   :                     : TBD",
    "MGC"           : "360  : FMT_DP   :                     : TBD",
    "MKTIME"        : "B28  : FMT_DP   :                     : TBD",
    "NEGTORK"       : "32   : FMT_DEC  :                     : TBD",          // P, U, V
    "NN"            : "B0   : FMT_DEC  :                     : TBD",
    "OFFSET"        : "B29  : FMT_DP   :                     : TBD",
    "OGC"           : "360  : FMT_DP   :                     : TBD",
    "OMEGA"         : "45   : FMT_SP   :                     : TBD",
    "OPTION"        : "B0   : FMT_OCT  :                     : TBD",          // 1, 2
    "OPTMODES"      : "B0   : FMT_OCT  :                     : TBD",
    "PACTOFF"       : "B14  : FMT_SP   : FormatXACTOFF       : TBD",
    "PAXERR1"       : "360  : FMT_SP   :                     : TBD",
    "PCMD"          : "B14  : FMT_SP   : FormatXACTOFF       : TBD",
    "PIPA"          : "B14  : FMT_SP   :                     : TBD",          // X, Y, Z
    "PIPTIME"       : "B28  : FMT_DP   :                     : TBD",
    "POSTORK"       : "32   : FMT_DEC  :                     : TBD",          // P, U, V
    "PREL"          : "1800 : FMT_SP   :                     : TBD",
    "PSEUDO55"      : "B14  : FMT_SP   : FormatGtc           : TBD",
    "QREL"          : "1800 : FMT_SP   :                     : TBD",
    "R-OTHER"       : "B29  : FMT_DP   :                     : TBD",
    "RADMODES"      : "B0   : FMT_OCT  :                     : TBD",
    "RANGE"         : "B29  : FMT_DP   :                     : TBD",
    "RANGRDOT"      : "B0   : FMT_2OCT :                     : TBD",
    "RCSFLAGS"      : "B0   : FMT_OCT  :                     : TBD",
    "RDOT"          : "B0   : FMT_DP   : FormatRDOT          : TBD",
    "REDOCTR"       : "B0   : FMT_DEC  :                     : TBD",
    "REFSMMAT"      : "2    : FMT_DP   :                     : TBD",
    "RGU"           : "B24  : FMT_DP   :                     : TBD",
    "RLS"           : "B27  : FMT_DP   :                     : TBD",
    "RM"            : "100  : FMT_DEC  :                     : TBD",
    "RN"            : "B29  : FMT_DP   :                     : TBD",
    "ROLLC"         : "360  : FMT_SP   :                     : TBD",
    "ROLLTM"        : "180  : FMT_SP   :                     : TBD",
    "RRATE"         : "B7   : FMT_DP   :                     : TBD",
    "RREL"          : "1800 : FMT_SP   :                     : TBD",
    "RSBBQ"         : "B0   : FMT_OCT  :                     : TBD",
    "RTARG"         : "B29  : FMT_DP   :                     : TBD",
    "RTHETA"        : "360  : FMT_DP   :                     : TBD",
    "STARSAV"       : "2    : FMT_DP   :                     : TBD",
    "STATE"         : "B0   : FMT_2OCT :                     : TBD",
    "SYNC"          : "B0   : FMT_OCT  :                     : TBD",
    "T-OTHER"       : "B28  : FMT_DP   :                     : TBD",
    "TALIGN"        : "B28  : FMT_DP   :                     : TBD",
    "TANGNB"        : "360  : FMT_SP   :                     : TBD",
    "TCDH"          : "B28  : FMT_DP   :                     : TBD",
    "TCSI"          : "B28  : FMT_DP   :                     : TBD",
    "TET"           : "B28  : FMT_DP   :                     : TBD",
    "TEVENT"        : "B28  : FMT_DP   :                     : TBD",
    "TGO"           : "B28  : FMT_DP   :                     : TBD",
    "THETA"         : "360  : FMT_SP   :                     : °",
    "TIG"           : "B28  : FMT_DP   :                     : TBD",
    "TIME"          : "B28  : FMT_DP   :                     : TBD",
    "TLAND"         : "B28  : FMT_DP   :                     : TBD",
    "TPASS4"        : "B28  : FMT_DP   :                     : TBD",
    "TRKMKCNT"      : "B0   : FMT_DEC  :                     : TBD",
    "TTE"           : "B28  : FMT_DP   :                     : TBD",
    "TTF/8"         : "B17  : FMT_DP   :                     : TBD",
    "TTOGO"         : "B28  : FMT_DP   :                     : TBD",
    "TTPF"          : "B28  : FMT_DP   :                     : TBD",
    "TTPI"          : "B28  : FMT_DP   :                     : TBD",
    "UNFC/2"        : "B0   : FMT_DP   :                     : TBD",
    "UPBUFF"        : "B0   : FMT_2OCT :                     : TBD",
    "UPCOUNT"       : "B0   : FMT_OCT  :                     : TBD",
    "UPOLDMOD"      : "B0   : FMT_DEC  :                     : TBD",
    "UPVERB"        : "B0   : FMT_DEC  :                     : TBD",
    "V-OTHER"       : "B7   : FMT_DP   :                     : TBD",
    "VG VEC"        : "B7   : FMT_DP   :                     : TBD",
    "VGTIG"         : "B7   : FMT_DP   :                     : TBD",
    "VGU"           : "B10  : FMT_DP   :                     : TBD",
    "VHFCNT"        : "B0   : FMT_DEC  :                     : TBD",
    "VHFTIME"       : "B28  : FMT_DP   :                     : TBD",
    "VIO"           : "B7   : FMT_DP   :                     : TBD",
    "VMEAS"         : "B28  : FMT_DP   :                     : TBD",
    "VN"            : "B7   : FMT_DP   :                     : TBD",
    "VPRED"         : "B7   : FMT_DP   :                     : TBD",
    "VSELECT"       : "B0   : FMT_DEC  :                     : TBD",
    "WBODY"         : "450  : FMT_DP   : FormatAdotsOrOga    : TBD",
    "X789"          : "B5   : FMT_SP   : FormatEarthOrMoonDP : TBD",
    "YACTOFF"       : "B14  : FMT_SP   : FormatXACTOFF       : TBD",
    "YCMD"          : "B14  : FMT_SP   : FormatXACTOFF       : TBD",
    "YNBSAV"        : "B1   : FMT_DP   :                     : TBD",
    "ZDOTD"         : "B7   : FMT_DP   :                     : TBD",
    "ZNBSAV"        : "B1   : FMT_DP   :                     : TBD",

    "SVMRKDAT"      : "B28 :  FMT_DP   :                     : TBD",
    "SVMRKDAT+2"    : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+3"    : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+4"    : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+5"    : "45  :  FMT_SP   : FormatOTRUNNION     : TBD",
    "SVMRKDAT+6"    : "360 :  FMT_USP  :                     : TBD",

    "SVMRKDAT+7"    : "B28 :  FMT_DP   :                     : TBD",
    "SVMRKDAT+9"    : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+10"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+11"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+12"   : "45  :  FMT_SP   : FormatOTRUNNION     : TBD",
    "SVMRKDAT+13"   : "360 :  FMT_USP  :                     : TBD",

    "SVMRKDAT+14"   : "B28 :  FMT_DP   :                     : TBD",
    "SVMRKDAT+16"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+17"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+18"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+19"   : "45  :  FMT_SP   : FormatOTRUNNION     : TBD",
    "SVMRKDAT+20"   : "360 :  FMT_USP  :                     : TBD",

    "SVMRKDAT+21"   : "B28 :  FMT_DP   :                     : TBD",
    "SVMRKDAT+23"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+24"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+25"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+26"   : "45  :  FMT_SP   : FormatOTRUNNION     : TBD",
    "SVMRKDAT+27"   : "360 :  FMT_USP  :                     : TBD",

    "SVMRKDAT+28"   : "B28 :  FMT_DP   :                     : TBD",
    "SVMRKDAT+30"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+31"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+32"   : "360 :  FMT_USP  :                     : TBD",
    "SVMRKDAT+33"   : "45  :  FMT_SP   : FormatOTRUNNION     : TBD",
    "SVMRKDAT+34"   : "360 :  FMT_USP  :                     : TBD",

    "YCDU"          : "B0  :  FMT_OCT  :                     : TBD",     // CM-77775
    "SCDU"          : "B0  :  FMT_OCT  :                     : TBD",
    "ZCDU"          : "B0  :  FMT_OCT  :                     : TBD",
    "TCDU"          : "B0  :  FMT_OCT  :                     : TBD",
    "XCDU"          : "B0  :  FMT_OCT  :                     : TBD",

]

let lookupGsopNames: [Substring : Substring] = [
//                     DNRRANGE+XX
    "AGSK"          : "K-FACTOR",
    "AIG"           : "CDU Y",
    "AMG"           : "CDU Z",
    "AOG"           : "CDU X",
    "AOTCODE"       : "AOT CODE",
    "BESTI"         : "STAR1 ID",
    "BESTJ"         : "STAR2 ID",
    "CDUS"          : "RR SHAFT",
    "CDUT"          : "RR TRUN",
    "CDUXD"         : "CDU XD",
    "CDUYD"         : "CDU YD",
    "CDUZD"         : "CDU ZD",
    "DNRRANGE"      : "RR RANGE",
    "DNRRDOT"       : "RR RRATE",
    "DELLT4"        : "TF CONIC",
    "REDOCTR"       : "REDO CTR",
    "RLS"           : "L SITE X",
    "RLS+2"         : "L SITE Y",
    "RLS+4"         : "L SITE X",
    "TRKMKCNT"      : "MARK CNT",

    "TCSI"          : "CSI TIME",
    "DELVEET1"      : "CSI ΔV X",
    "DELVEET1+2"    : "CSI ΔV Y",
    "DELVEET1+4"    : "CSI ΔV Z",

    "DELVEET"       : "CSI ΔV X",
    "DELVEET+2"     : "CSI ΔV Y",
    "DELVEET+4"     : "CSI ΔV Z",

    "TCDH"          : "CDH TIME",
    "DELVEET2"      : "CDH ΔV X",
    "DELVEET2+2"    : "CDH ΔV Y",
    "DELVEET2+4"    : "CDH ΔV Z",

    "TTPI"          : "TPI TIME",
    "DELVEET3"      : "TPI ΔV X",
    "DELVEET3+2"    : "TPI ΔV Y",
    "DELVEET3+4"    : "TPI ΔV Z",

    "TPASS4"        : "TPF TIME",

    "X789"          : "Δ BETA",
    "X789+2"        : "Δ THETA",

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
]
