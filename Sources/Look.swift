//
//  Look.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on Mar12/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ║     CDUT        The optics trunnion angle CDU, scaled (degrees-19.7754)/45 (two's complement).   ║
  ║                 The angle varies from -19.775° to +45°.                                          ║
  ║     PIPTIME     units = centiSecond (not "oneOct"?)                                              ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ .. assorted lookup tables ..                                                                     │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

let lookupScaleFormatUnits = [
    "RN"            : "B29  : FMT_DP   :                     : m",      // STATE VECTOR (POS)
    "VN"            : "B7   : FMT_DP   :                     : m/cS",   // STATE VECTOR (VEL)
    "PIPTIME"       : "B28  : FMT_DP   :                     : cSec",   // STATE VECTOR (TIME)

    "CDUX"          : "360  : FMT_SP   :                     : deg",    // outer gimbal
    "CDUY"          : "360  : FMT_SP   :                     : deg",    // inner gimbal
    "CDUZ"          : "360  : FMT_SP   :                     : deg",    // middle gimbal

    "8NN"           : "B0   : FMT_DEC  :                     : TBD",
    "ADOT"          : "450  : FMT_DP   : FormatAdotsOrOga    : TBD",
    "AGSK"          : "B28  : FMT_DP   :                     : TBD",
    "AIG"           : "360  : FMT_SP   :                     : TBD",
    "AK"            : "180  : FMT_SP   :                     : TBD",    // roll,pitch,yaw for FDAI display
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
    "RSP-RREC"      : "360  : FMT_DP   :                     : TBD",    // == DELTAR
    "DELV"          : "B14  : FMT_DP   : FormatDELV          : TBD",
    "DELVEET"       : "B7   : FMT_DP   :                     : TBD",
    "DELVEET1"      : "B7   : FMT_DP   :                     : TBD",
    "DELVEET2"      : "B7   : FMT_DP   :                     : TBD",
    "DELVEET3"      : "B7   : FMT_DP   :                     : TBD",
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
    "ERROR"         : "180  : FMT_SP   :                     : TBD",    // X, Y, Z
    "FAILREG"       : "B0   : FMT_OCT  :                     : TBD",
    "FC"            : "B14  : FMT_SP   : FormatGtc           : TBD",
    "GAMMAEI"       : "360  : FMT_DP   :                     : TBD",
    "GSAV"          : "2    : FMT_DP   :                     : TBD",
    "HAPO"          : "B29  : FMT_DP   :                     : TBD",
    "HPER"          : "B29  : FMT_DP   :                     : TBD",
    "HMEAS"         : "B28  : FMT_DP   : FormatHMEAS         : TBD",
    "HOLDFLAG"      : "B0   : FMT_DEC  :                     : TBD",
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
    "MARK2DWN"      : "B28  : FMT_DP   :                     : TBD",    //###
    "MARK2DWN+2"    : "360  : FMT_USP  :                     : TBD",
    "MARK2DWN+3"    : "360  : FMT_USP  :                     : TBD",
    "MARK2DWN+4"    : "360  : FMT_USP  :                     : TBD",
    "MARK2DWN+5"    : "360  : FMT_USP  :                     : TBD",
    "MARK2DWN+6"    : "45   : FMT_SP   : FormatOTRUNNION     : TBD",
    "MARKDOWN"      : "B28  : FMT_DP   :                     : TBD",    //###
    "MARKDOWN+2"    : "360  : FMT_USP  :                     : TBD",
    "MARKDOWN+3"    : "360  : FMT_USP  :                     : TBD",
    "MARKDOWN+4"    : "360  : FMT_USP  :                     : TBD",
    "MARKDOWN+5"    : "360  : FMT_USP  :                     : TBD",
    "MARKDOWN+6"    : "45   : FMT_SP   : FormatOTRUNNION     : TBD",
    "MARKTIME"      : "B28  : FMT_DP   :                     : TBD",
    "MGC"           : "360  : FMT_DP   :                     : TBD",
    "MKTIME"        : "B28  : FMT_DP   :                     : TBD",
    "NEGTORK"       : "32   : FMT_DEC  :                     : TBD",    // P, U, V
    "NN"            : "B0   : FMT_DEC  :                     : TBD",
    "OFFSET"        : "B29  : FMT_DP   :                     : TBD",
    "OGC"           : "360  : FMT_DP   :                     : TBD",
    "OMEGA"         : "45   : FMT_SP   :                     : TBD",
    "OPTION"        : "B0   : FMT_OCT  :                     : TBD",    // 1, 2
    "OPTMODES"      : "B0   : FMT_OCT  :                     : TBD",
    "PACTOFF"       : "B14  : FMT_SP   : FormatXACTOFF       : TBD",
    "PAXERR1"       : "360  : FMT_SP   :                     : TBD",
    "PCMD"          : "B14  : FMT_SP   : FormatXACTOFF       : TBD",
    "PIPA"          : "B14  : FMT_SP   :                     : TBD",    // X, Y, Z
    "POSTORK"       : "32   : FMT_DEC  :                     : TBD",    // P, U, V
    "PREL"          : "1800 : FMT_SP   :                     : TBD",
    "PSEUDO55"      : "B14  : FMT_SP   : FormatGtc           : TBD",
    "QREL"          : "1800 : FMT_SP   :                     : TBD",
    "R-OTHER"       : "B29  : FMT_DP   :                     : TBD",
    "RADMODES"      : "B0   : FMT_OCT  :                     : TBD",
    "RANGE"         : "B29  : FMT_DP   :                     : TBD",
    "RANGRDOT"      : "B0   : FMT_SP   :                     : TBD",    //Apr01: 2OCT -? FMT_SP
    "RCSFLAGS"      : "B0   : FMT_OCT  :                     : TBD",
    "RDOT"          : "B0   : FMT_DP   : FormatRDOT          : TBD",
    "REDOCTR"       : "B0   : FMT_DEC  :                     : TBD",
    "REFSMMAT"      : "2    : FMT_DP   :                     : TBD",
    "RGU"           : "B24  : FMT_DP   :                     : TBD",
    "RLS"           : "B27  : FMT_DP   :                     : TBD",
    "RM"            : "100  : FMT_DEC  :                     : TBD",
    "RR_DIST"       : "B0   : FMT_SP   :                     : TBD",    //###Apr01/25
    "RR_RATE"       : "B0   : FMT_SP   :                     : TBD",    //###Apr01/25
    "ROLLC"         : "360  : FMT_SP   :                     : TBD",
    "ROLLTM"        : "180  : FMT_SP   :                     : TBD",
    "RRATE"         : "B7   : FMT_DP   :                     : TBD",
    "RREL"          : "1800 : FMT_SP   :                     : TBD",
    "RSBBQ"         : "B0   : FMT_OCT  :                     : TBD",
    "RTARG"         : "B29  : FMT_DP   :                     : TBD",
    "RTHETA"        : "360  : FMT_DP   :                     : TBD",
    "STARSAV1"      : "2    : FMT_DP   :                     : TBD",
    "STARSAV2"      : "2    : FMT_DP   :                     : TBD",
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
    "THETAD"        : "360  : FMT_SP   :                     : deg",    //### Luminary099
    "THETADX"       : "360  : FMT_SP   :                     : deg",
    "THETADY"       : "360  : FMT_SP   :                     : deg",
    "THETADZ"       : "360  : FMT_SP   :                     : deg",
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
    "VPRED"         : "B7   : FMT_DP   :                     : TBD",
    "VSELECT"       : "B0   : FMT_DEC  :                     : TBD",
    "WBODY"         : "450  : FMT_DP   : FormatAdotsOrOga    : TBD",
    "X789"          : "B5   : FMT_DP   : FormatEarthOrMoonDP : TBD",    //### Apr01: FMT_SP → FMT_DP
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

    // Skylark048                                                       (annotations from ERASABLE_ASSIGNMENTS.agc)
    //                                                                  (and from GSOP-Skylark048))

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆     THE SIZE AND UTILIZATION OF AN ERASABLE ARE OFTEN INCLUDED IN                                ┆
  ┆     THE COMMENTS IN THE FOLLOWING FORM.  M(SIZE)N.                                               ┆
  ┆                                                                                                  ┆
  ┆         M: REFERS TO THE MOBILITY OF THE ASSIGNMENT.                                             ┆
  ┆             B:   THE SYMBOL IS REFERENCED BY BASIC INSTRUCTIONS THUS IS E-BANK SENSITIVE.        ┆
  ┆             I:   THE SYMBOL IS REFERENCED ONLY BY INTERPRETIVE INSTRUCTIONS, AND IS E-BANK       ┆
  ┆                  INSENSITIVE AND MAY APPEAR IN ANY E-BANK.                                       ┆
  ┆                                                                                                  ┆
  ┆         SIZE: IS THE NUMBER OF REGISTERS INCLUDED BY THE SYMBOL.                                 ┆
  ┆                                                                                                  ┆
  ┆         N: INDICATES THE NATURE OR PERMANENCE OF THE CONTENTS.                                   ┆
  ┆             PL:  MEANS THAT THE CONTENTS ARE PAD LOADED.                                         ┆
  ┆             DSP: MEANS THAT THE REGISTER IS USED FOR A DISPLAY.                                  ┆
  ┆             PRM: MEANS THAT THE REGISTER IS PERMANENT, IE. IT IS USED DURING THE ENTIRE          ┆
  ┆                  MISSION FOR ONE PURPOSE AND CANNOT BE SHARED.                                   ┆
  ┆             TMP: MEANS THAT THE REGISTER IS USED TEMPORARILY OR IS A SCRATCH REGISTER FOR        ┆
  ┆                  THE ROUTINE TO WHICH IT IS ASSIGNED.  THAT IS, IT NEED NOT BE SET PRIOR TO      ┆
  ┆                  INVOCATION OF THE ROUTINE NOR DOES IT CONTAIN USEFUL OUTPUT TO ANOTHER ROUTINE. ┆
  ┆                  THUS IT MAY BE SHARED WITH ANY OTHER ROUTINE WHICH IS NOT ACTIVE IN PARALLEL.   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

    "SLOPE"         : "B0  :  FMT_DEC  : FormatRequired      : TBD",    // EQUALS   CDUZD   +2      # B(1)TMP
                                                                        // A DAP quantity specifying the slope of the phase plane
                                                                        // boundaries, scaled ((degrees/second)/degree)/2.5

    "ADB"           : "B0  :  FMT_OCT  : FormatRequired      : TBD",    // EQUALS   SLOPE   +1      # B(1)TMP

    "CH5FAIL"       : "B0  :  FMT_OCT  : FormatRequired      : TBD",    // ERASE                    # B(1)
    "CH6FAIL"       : "B0  :  FMT_OCT  : FormatRequired      : TBD",    // ERASE                    # B(1)
    "DKRATE"        : "B0  :  FMT_OCT  : FormatRequired      : TBD",    // ERASE                    # B(1)
    "DKDB"          : "B0  :  FMT_OCT  : FormatRequired      : TBD",    // ERASE                    # B(1)
    "WHICHDAP"      : "B0  :  FMT_OCT  : FormatRequired      : TBD",    // ERASE                    # B(1)

    "SVEC+2"        : "B6  :  FMT_2DEC : FormatRequired      : TBD",    // EQUALS   VHF.W   +18D    # B(8)
                                                                        // The R27 range rate, scaled (meters/centiS)/2^6

    "FIXTIME"       : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // ERASE            +1      # B(2)
    "DVTOTAL###"    : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS   SBDELT  +1      # B(2)DSP - NOUN 40,99 FOR P30,34,35,40
    "NC1TIG"        : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS   VGDISP  +2      # I(2)
    "NC2TIG"        : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS   NC1TIG  +2      # I(2)

    "DHDSP"         : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS   PI      +2      # I(2)
    "DVDSP1"        : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS   RAH2    +6      # I(2)
    "DVDSP2"        : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS   DVDSP1  +2      # I(2)

    "UTPIT"         : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS   PLANVCUT +6     # I(2)  N78 PITCH
    "UTYAW"         : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS   UTPIT   +2      # I(2)  N78 YAW

    "THETAH"        : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS    RDOT   +2      #   2P  DSP NOUN 64,67 FOR P63,64,67
    "TEPHEM"        : "B0  :  FMT_OCT  : FormatRequired      : TBD",    // EQUALS    LIFTTEMP +2    #  (3)TMP

    // Sundance306ish (unique)                                          (annotations from ERASABLE_ASSIGNMENTS.agc)

    "MASS"          : "B24 :  FMT_DP   :                     : Kg",     // EQUALS   GDT/2   +6      # B(2)

    "SUMRATEQ"      : "90  :  FMT_DEC  : FormatRequired      : r/S",    //                          # SUM OF UN-WEIGHTED JETRATE TERMS
    "SUMRATER"      : "90  :  FMT_DEC  : FormatRequired      : r/S",    //                          # SCALED AT PI/4 RADIANS/SECOND

    "VRPREV"        : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS  VG      +6       # I(6)TMP
    "PIF"           : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // ERASE                    # B(2)      THROTTLE
    "GDT/2"         : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // ERASE           +22D     # B(6)TMP
    "STARAD"        : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS  ZDC     +6       # I(18D)TMP
    "STAR"          : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS  STARAD  +18D     # I(6)

    "AGSBUFF"       : "B0  :  FMT_2OCT : FormatRequired      : TBD",    // EQUALS  RANGE            # B(14D)

    // Zerlina56

    "LRTIMEDL"      : "B0  :  FMT_2OCT : FormatRequired      : TBD",    //

    // Luminary163

    "LATVEL"        : "B0  :  FMT_DEC   :                    : f/S",    //
    "FORVEL"        : "B0  :  FMT_DEC   :                    : f/S",    //

    // Luminary210                                                        (annotations from GSOP-Luminary1E)

    "TRUDELH"       : "B24 :  FMT_DP   :                     : m",      // 3    Difference in LR measured altitude and calculated
                                                                        //      altitude where calculated altitude is with respect to
                                                                        //      landing site radius. Scaled meters/2^24. Calculated
                                                                        //      every ~2 seconds during altitude updates.

    "GTCTIME"       : "B28 :  FMT_DP   :                     : cS",     // 6    Double precision sampled PIPTIME of the Average-G
                                                                        //      cycle for which the guidance thrust command is computed.
                                                                        //      Scaled centiseconds/2^28, referenced to the computer clock.

    "LATVMETR"      : "B0  :  FMT_DEC   :                    : f/S",    // 12a
    "FORVMETR"      : "B0  :  FMT_DEC   :                    : f/S",    // 12b  Lateral and forward velocity. During descent the orthogonal
                                                                        //      components of the horizontal velocity of the vehicle with
                                                                        //      respect to the moon, which are essentially parallel and
                                                                        //      perpendicular to the X-Z plane of the vehicle. During ascent
                                                                        //      and aborts, lateral velocity is the inertial cross axis
                                                                        //      velocity, and forward velocity is set equal to zero. It is
                                                                        //      scaled, (ft/sec) / (0.5571 x 2^14) and is computed and
                                                                        //      displayed four times per second.

    "AGSCODE"       : "B0  :  FMT_OCT   :                    : TBD",    // 16a  AGSCODE (AGS Composite Code Word). An octal number used to
                                                                        //      indicate to the AGS whether RR Data is acceptable. Set by R22 to
                                                                        //      57776g for high range scale, and 17776g for low range scale RR Data
                                                                        //      when a successful RR read is made and the time since the last setting
                                                                        //      is greater than =^50 seconds. Reset to 20000g (indicating that
                                                                        //      the AGS should not accept mark data) by R21, R65, R56, Fresh
                                                                        //      Start, and hardware and software restarts.

    "SERVDURN"      : "B14 :  FMT_SP   :                     : TBD",    // 67a  SERVDURN. The Average-G cycle duration which is computed
                                                                        //      as the difference between TIMEl and the least significant
                                                                        //      half of PIPTIME at exit from the Average-G in SERVICER.
                                                                        //      It is a measure of TLOSS; the greater the TLOSS, the larger
                                                                        //      that time will be. The quantity is scaled centiseconds/2^14
                                                                        //      and is, corrected for overflow (always >0).

    "DUMLOOPS"      : "B14 :  FMT_SP   :                     : TBD",    // 67b  DUMLOOPS. The number of passes through Dummy Job,
                                                                        //      scaled counts/2^14. The register is incremented when there is
                                                                        //      less than 100% duty cycle to indicate relative amounts of
                                                                        //      DUMMYJOB activity at various times. The rate at which it is
                                                                        //      incremented indicates the amount of available processing time.

    "DVTOTAL"       : "B7  :  FMT_2DEC :                     : TBD",    // 78   DVTOTAL. The magnitude of the measured Delta V. It is
                                                                        //      calculated in SERVICER, every 2 seconds. The absolute value
                                                                        //      of the velocity gained in the preceding 2—second interval is
                                                                        //      calculated and added to DVTOTAL. giving a running sum. Its
                                                                        //      value will be zero until TIG-30 and should not change, except
                                                                        //      for PIPA bias, until Ullage comes on. If SURFFLAG is set.
                                                                        //      DVTOTAL is not incremented. During burns, the range of
                                                                        //      DVTOTAL will vary from zero to the magnitude of the Delta V
                                                                        //      to be burned. Variation in value increases as the burn is )
                                                                        //      carried out. DVTOTAL is scaled (meters/centisecond)/2.

    "CH5MASK"       : "B0  :  FMT_OCT  :                     : TBD",    // 89a
    "CH6MASK"       : "B0  :  FMT_OCT  :                     : TBD",    // 89b

    "ALMCADR"       : "B0  :  FMT_2OCT :                     : TBD",    // 99   ALMCADR. Complete address of memory location where the
                                                                        //      most recent alarm was generated. Double precision quantity;
                                                                        //      the high order contains ADRES^ the low order contains BBCON'.'

    "TSIGHT"        : "B0  :  FMT_2OCT :                     : TBD",    // 99   TSIGHT. The time at which the mark button was depressed to
                                                                        //      store IMU gimbal angles during lunar surface alignment (AOT
                                                                        //      Mark Time). It is scaled, centiseconds/2^28

    "AOT CURSOR"    : "360 :  FMT_USP :                      : deg",    // 100a Cursor Angle. The SP rotation angle of the AOT cursor about
                                                                        //      the AOT optics axis used to locate a celestial body with re-
                                                                        //      spect to the LM body axis during lunar surface alignments.
                                                                        //      It is calculated in R59 for a specified celestial body, dis-
                                                                        //      played in R1 'N79) and keyed in by astronaut during the mark-
                                                                        //      ing sequence (N79). It is an unsigned 15-bit fraction, scaled
                                                                        //      degrees/360.

    "SPIRAL"        : "360 :  FMT_USP :                      : deg",    // 100b Spiral Angle. The SP rotation angle of the AOT spiral about
                                                                        //      the AOT optics axis used to locate a celestial body with re-
                                                                        //      spect to the LM body axis during lunar surface alignments.
                                                                        //      It is calculated in R59 for a specified celestial body, dis-
                                                                        //      played in R.2 (N79) and keyed in by astronaut during the mark-
                                                                        //      ing sequence {N79). It is an unsigned 15-bit fraction, scaled
                                                                        //      degrees/360.
]

let forceSingle = [
    "TANGNB",
    "RSBBQ",
    "OPTION",
//  "LRTIMEDL",         //### Apr01/25
    "FC",
    "CHANBKUP",         //### Apr01/25
//  "PIF",              //### Apr01/25
    "VHFCNT",
    "NN",
    "RM",
]

let forceDouble = [
    "AGSK",             //### "K FACTOR" (GSOP)
//  "CHANBKUP",         //### Apr01/25
    "PIF",              //### Apr01/25
    "DELV",
    "DELVEET1",
    "DSPTAB",
    "GSAV",
    "R-OTHER",
    "REFSMMAT",
    "RLS",
    "RN",
    "STARSAV1",
    "STARSAV2",
    "STATE",
    "TCDH",
    "TIME2",
    "UPBUF",
    "UPBUFF",
    "VGTIG",
    "VN",

    // 77775

    "CENTANG",
    "DELVSLV",
    "DELVTPF",
    "RTHETA",
    "RDOTM",
    "SVEC",
//  "DHDSP",

    // 77774

    "DELLT4",
    "ELEV",
    "GDT/2",            // Sundance306ish Apr01/25
    "VRPREV",           // Sundance306ish Apr01/25
    
    "TCSI",
    "TPASS4",
    "DELVEET2",
    "DELVEET3",
    "DIFFALT",
    "TTPI",
    "RTARG",
    "TGO",
//  "MARKTIME",         //### to be checked
    "MASS",

    // 77773

    "LRVTIMDL",
    "VMEAS",
    "MKTIME",
    "HMEASDL",
    "HMEAS",
//  "RM",               // CM-77775 has single precision
    "UNFC/2",
    "TTF/8",
    "DELTAH",
    "RGU",
    "VGU",
    "LAND",
    "AT",
    "TLAND",
    "TTOGO",
    "ZDOTD",
    "X789",

    //77772

    "YNBSAV",
    "ZNBSAV",

    "PIPTIME",          //###
    "T-OTHER",          //###
    "TALIGN",           //###
    "TEVENT",           //###
    "TIG",              //###
    "V-OTHER",          //###

    // CM77777

    "RSP-RREC",
    "DELTAR",
    "LAUNCHAZ",
    "TET",
    "WBODY",

    // 77775

    "ADOT",
    "VHFTIME",
    "DELVSLV",
    "DELTAR",
    "WBODY",
    "GAMMAEI",          //### MAR10

    // 77776

    "L/D1",
    "TTE",
    "VIO",
    "VPRED",

    // 77774

    "PIPTIME1",
    "DELV",

    // 77773

    "LAT",
    "LONG",
    "ALT",

    "ALMCADR",          //###MAR11 Luminary210
    "TRUDELH",
    "GTCTIME",
    "DVTOTAL",

    // 77777

    "STARAD",           // Sundance306ish Apr01/25
    "STAR",             // Sundance306ish Apr01/25
]

let missionLookUp = [
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  Command Modules ..                                                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
//  "Colossus237" : "Apollo 8 CM - Colossus 1",                     // R-577-sec2-rev2.pdf (p2-20)
    "Colossus249" : "Apollo 9 CM - Colossus 1A",                    // R-577-sec2-rev2.pdf
//  "Comanche044" : "Apollo 10 CM - Colossus 2 (not flown)",
//  "Comanche045" : "Apollo 10 CM - Colossus 2 (not flown)",
    "Manche45R2"  : "Apollo 10 CM - Colossus 2",
//  "Comanche051" : "Apollo 11 CM - Colossus 2A (not flown)",
//  "Comanche055" : "Apollo 11 CM - Colossus 2A",
//  "Comanche067" : "Apollo 12 CM - Colossus 2C",
//  "Comanche072" : "Apollo 13 CM - Colossus 2D (not flown)",
//  "Manche72R3"  : "Apollo 13 CM - Colossus 2D",
    "Artemis072"  : "Apollo 15/16/17 CM - Colossus 3",
    "Skylark048"  : "Skylab 2/3/4 CM - Colossus 2E",                // R-693-Sec2-RevX
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  Lunar Modules ..                                                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    "Sundance306ish" : "Apollo 9 LM (not flown)",
//  "SundanceXXX" : "Apollo 9 LM",
    "LUM69R2"     : "Apollo 10 LM - Luminary 1",                    //### Apr02/25
//  "Luminary096" : "Apollo 11 LM - Luminary 1A (not flown)",
//  "Luminary097" : "Apollo 11 LM - Luminary 1A (not flown)",
//  "Luminary098" : "Apollo 11 LM - Luminary 1A (not flown)",
    "Luminary099" : "Apollo 11 LM - Luminary 1A",
    "Luminary116" : "Apollo 12 LM - Luminary 1B",
//  "Luminary130" : "Apollo 13 LM - Luminary 1C (not flown)",
//  "Luminary131" : "Apollo 13 LM - Luminary 1C",
    "LM131R1"     : "Apollo 13 LM - Luminary 1C",                   // R-567-sec2-rev8.pdf
    "Zerlina56"   : "Experimental LM (not flown)",
    "Luminary163" : "Apollo 14 LM - Luminary 1D (not flown)",
//  "Luminary173" : "Apollo 14 LM - Luminary 1D (not flown)",
    "Luminary178" : "Apollo 14 LM - Luminary 1D",                   //### Apr02/25
    "Luminary210" : "Apollo 15/16/16 LM - Luminary 1E"              // R-567-sec2-rev12.pdf
]

let downListIDs = [

    "CMPG22DL" : "Program 22 (CM-77773)",
    "CMPOWEDL" : "Powered (CM-77774)",
    "CMRENDDL" : "Rendezvous and Prethrust (CM-77775)",
    "CMENTRDL" : "Entry and Update (CM-77776)",
    "CMCSTADL" : "Coast and Align (CM-77777)",

    "LMLSALDL" : "Surface Align (LM-77772)",
    "LMDSASDL" : "Descent and Ascent (LM-77773)",
    "LMORBMDL" : "Orbital Maneuvers (LM-77774)",
    "LMRENDDL" : "Rendezvous/Prethrust (LM-77775)",
    "LMAGSIDL" : "AGS Initialization and Update (LM-77776)",
    "LMCSTADL" : "Coast and Align (LM-77777)",

    // Zerlina onwards (LM)

    "SURFALIN" : "Surface Align (LM-77772)",
    "DESC/ASC" : "Descent and Ascent (LM-77773)",
    "ORBMANUV" : "Orbital Maneuvers (LM-77774)",
    "RENDEZVU" : "Rendezvous/Prethrust (LM-77775)",
    "AGSI/UPD" : "AGS Initialization and Update (LM-77776)",
    "COSTALIN" : "Coast and Align (LM-77777)",

    // Sundance306ish

    "LMPWRDDL" : "Powered (LM-77774)",

]

#if false
func getMissionListURL(_ mission: String, _ list: String) -> String? {

    return [
        "LM131R1+77772": "https://www.ibiblio.org/apollo/NARA-SW/R-567-sec2-rev8.pdf#page=126",
        "LM131R1+77773": "https://www.ibiblio.org/apollo/NARA-SW/R-567-sec2-rev8.pdf#page=120",
        "LM131R1+77774": "https://www.ibiblio.org/apollo/NARA-SW/R-567-sec2-rev8.pdf#page=44",
        "LM131R1+77775": "https://www.ibiblio.org/apollo/NARA-SW/R-567-sec2-rev8.pdf#page=114",
        "LM131R1+77776": "https://www.ibiblio.org/apollo/NARA-SW/R-567-sec2-rev8.pdf#page=130",
        "LM131R1+77777": "https://www.ibiblio.org/apollo/NARA-SW/R-567-sec2-rev8.pdf#page=108",
    ][mission + "+" + list]

}

func addCommentary(missionName: String, downList: String, itemIndex: Int) -> String? {

    switch missionName {
        case "Colossus249":
            switch downList {
                case "77773": return [
                    100: """
                            # comment before TIME2,TIME1
                            """,
                    9: "",
                ][itemIndex]
                case "77774": return [
                    100: """
                            # comment before TIME2,TIME1
                            """,
                    9: "",
                ][itemIndex]
                case "77775": return [
                    100: """
                            # comment before TIME2,TIME1
                            """,
                    9: "",
                ][itemIndex]
                case "77776": return [
                    100: """
                            # comment before TIME2,TIME1
                            """,
                    9: "",
                ][itemIndex]
                case "77777": return [
                    100: """
                            # comment before TIME2,TIME1
                            """,
                    9: "",
                ][itemIndex]
                default: return nil
            }
        default : break
    }
    return nil
}
#endif
