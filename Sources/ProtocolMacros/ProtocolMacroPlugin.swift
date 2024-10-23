//
//  ProtocolMacroPlugin.swift
//  ProtocolMacro
//
//  Created by Fernando Lucheti on 22/10/24.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ProtocolMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ProtocolMacro.self,
    ]
}
