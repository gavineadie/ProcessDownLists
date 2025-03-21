//
//  Util.swift
//  ProcessDownLists
//
//  Created by Gavin Eadie on 2/9/25.
//

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TO BE FIXED:                                                                                     ║
  ║                                                                                                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation
import RegexBuilder

extension Collection {
    var isNotEmpty: Bool { !self.isEmpty }
}

extension StringProtocol {
    func padTo10(_ pad: String = " ") -> String { self.padding(toLength: 10, withPad: pad, startingAt: 0) }
    func padTo12(_ pad: String = " ") -> String { self.padding(toLength: 12, withPad: pad, startingAt: 0) }
    func padTo16(_ pad: String = " ") -> String { self.padding(toLength: 16, withPad: pad, startingAt: 0) }
    func padTo36(_ pad: String = " ") -> String { self.padding(toLength: 36, withPad: pad, startingAt: 0) }
    func padTo72(_ pad: String = " ") -> String { self.padding(toLength: 72, withPad: pad, startingAt: 0) }
}

func leftPad(_ s: String, _ n: Int) -> String {
    return (s.count <= 11) ? String(repeating: " ", count: n - s.count) + s : s
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ matches an AGC assembler line                                                                    │
  │ "LMNCSTA07  3DNADR  OGC                          # OGC,+1,IGC,+1,MGC,+1    COMMON DATA"          │
  │  < 1 ---->  < 2 ------>                            < 3 ------------------------------>           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func matchAssembler(_ line: String) -> (String, String, String) {
    let pattern = #/^(\S*)\s*(.*?)\s*(#.*)|^(\S*)\s*(.*)/#

    guard let match = line.wholeMatch(of: linePattern) else { return ("", "", "") }

    let label = String(match.1 ?? match.4 ?? "")
    let opcode = (match.2 ?? match.5 ?? "")
        .trimmingCharacters(in: .whitespaces)
        .replacing(#/\s+/#, with: " ", maxReplacements: 2)
    let comment = String(match.3 ?? "")

    return (label, opcode, comment)
}

let linePattern = Regex {
    ChoiceOf {
        Regex {
            Anchor.startOfLine
            Capture { ZeroOrMore(.whitespace.inverted) }
            ZeroOrMore(.whitespace)
            Capture { ZeroOrMore(.reluctant) { .anyGraphemeCluster } }
            ZeroOrMore(.whitespace)
            Capture {
                Regex {
                    "#"
                    ZeroOrMore { .anyGraphemeCluster }
                }
            }
        }

        Regex {
            Anchor.startOfLine
            Capture { ZeroOrMore(.whitespace.inverted) }
            ZeroOrMore(.whitespace)
            Capture { ZeroOrMore { .anyGraphemeCluster } }
        }
    }
}
