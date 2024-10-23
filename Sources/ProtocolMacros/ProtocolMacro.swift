//
//  ProtocolMacro.swift
//  ProtocolMacro
//
//  Created by Fernando Lucheti on 22/10/24.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum ProtocolMacroError: Error {
    case notClassOrStruct
}

public struct ProtocolMacro: PeerMacro {
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
                
        let classDecl = declaration.as(ClassDeclSyntax.self)
        let structDecl = declaration.as(StructDeclSyntax.self)
        
        if classDecl == nil && structDecl == nil {
            throw ProtocolMacroError.notClassOrStruct
        }
        
        let typeName = classDecl?.name.text ?? structDecl?.name.text ?? .empty
        let protocolName = typeName + "Protocol"
        
        let members = classDecl?.memberBlock.members ?? structDecl?.memberBlock.members ?? []
        let nonPrivateMembers: TypeMembers = extractNonPrivateMembers(members)
        
        let properties = stringify(nonPrivateMembers.properties)
        let functions = stringify(nonPrivateMembers.functions)
        
        let protocolDecl = ProtocolDeclSyntax(name: "\(raw: protocolName)",
                                              memberBlockBuilder: {
            """
            \(raw: properties)
            \(raw: functions)
            """
        })
        return [DeclSyntax(protocolDecl)]
    }
}

extension ProtocolMacro {
    
    private struct TypeMembers {
        var properties: [VariableDeclSyntax]
        var functions: [FunctionDeclSyntax]
    }
    
    private static func extractNonPrivateMembers(_ members: MemberBlockItemListSyntax) -> TypeMembers {
        var typeMembers = TypeMembers(properties: [], functions: [])
        members.forEach { member in
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               !varDecl.modifiers.contains(where: { $0.name.text.contains(Keywords.private) }) {
                typeMembers.properties.append(varDecl)
            }
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self),
               !funcDecl.modifiers.contains(where: { $0.name.text.contains(Keywords.private) }) {
                typeMembers.functions.append(funcDecl)
            }
        }
        return typeMembers
    }
    
    private static func stringify(_ properties: [VariableDeclSyntax]) -> String {
        properties.compactMap { varDecl in
            let propertyName = varDecl.bindings.first?.pattern.description
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let propertyType = varDecl.bindings.first?.typeAnnotation?.type.description
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? "Any"
            let accessors = varDecl.hasSetter ? "{ \(Keywords.get) \(Keywords.set) }" : "{ \(Keywords.get) }"
            return "\(Keywords.var) \(propertyName): \(propertyType) \(accessors)"
        }.joined(separator: "\n")
    }
    
    private static func stringify(_ functions: [FunctionDeclSyntax]) -> String {
        functions.compactMap { funcDecl in
            let funcName = funcDecl.name.text
            let parameters = funcDecl.signature.parameterClause.parameters.map { param in
                var parameterName = param.firstName.text
                if let secondParamName = param.secondName?.text {
                    parameterName += " \(secondParamName)"
                }
                let paramType = param.type.description
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return "\(parameterName): \(paramType)"
            }.joined(separator: ", ")
            let returnType = funcDecl.signature.returnClause?.type.description
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let returnSuffix = returnType.isEmpty ? .empty : " -> \(returnType)"
            return "\(Keywords.func) \(funcName)(\(parameters))\(returnSuffix)"
        }.joined(separator: "\n")
    }
}
