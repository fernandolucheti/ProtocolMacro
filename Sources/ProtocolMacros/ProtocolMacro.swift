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
        
        let genericParameters = classDecl?.genericParameterClause?.description ??
        structDecl?.genericParameterClause?.description ?? .empty
        let genericWhereClause = classDecl?.genericWhereClause?.description ??
        structDecl?.genericWhereClause?.description ?? .empty
        let associatedTypes = createAssociatedtypes(genericParameters, whereClause: genericWhereClause)
        
        let protocolDecl = ProtocolDeclSyntax(name: "\(raw: protocolName)",
                                              memberBlockBuilder: {
            """
            \(raw: associatedTypes)
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
            var modifiers: String = .empty
            if varDecl.modifiers.contains(where: { $0.name.text.contains(Keywords.static)}) {
                modifiers.append("\(Keywords.static) ")
            }
            return "\(modifiers)\(Keywords.var) \(propertyName): \(propertyType) \(accessors)"
        }.joined(separator: "\n")
    }
    
    private static func stringify(_ functions: [FunctionDeclSyntax]) -> String {
        functions.compactMap { funcDecl in
            let funcName = funcDecl.name.text
            var generics: String = .empty
            if let genericParameter = funcDecl.genericParameterClause?.description {
                generics = genericParameter
            }
            var whereClause: String = .empty
            if let genericWhereClause = funcDecl.genericWhereClause?.description {
                whereClause = " \(genericWhereClause)"
            }
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
            var modifiers: String = .empty
            if funcDecl.modifiers.contains(where: { $0.name.text.contains(Keywords.static)}) {
                modifiers.append("\(Keywords.static) ")
            }
            return "\(modifiers)\(Keywords.func) \(funcName)\(generics)(\(parameters))\(returnSuffix)\(whereClause)"
        }.joined(separator: "\n")
    }
    
    private static func createAssociatedtypes(_ genericClause: String, whereClause: String) -> String {
        guard !genericClause.isEmpty else { return .empty }
        return genericClause
            .replacingOccurrences(of: SyntaxTokens.leftAngleBracket, with: String.empty)
            .replacingOccurrences(of: SyntaxTokens.rightAngleBracket, with: String.empty)
            .replacingOccurrences(of: " ", with: String.empty)
            .components(separatedBy: ",")
            .map { genericType in
                var genericType = genericType
                let typeSpecifier = (whereClause
                    .replacingOccurrences(of: Keywords.where, with: String.empty)
                    .components(separatedBy: ",")
                    .first { typeIdentifier  in
                        typeIdentifier
                            .components(separatedBy: ":")
                            .first?
                            .trimmingCharacters(in: .whitespacesAndNewlines) == genericType
                    } ?? .empty)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !typeSpecifier.isEmpty {
                    genericType = typeSpecifier
                }
                return "\(Keywords.associatedtype) \(genericType)"
            }.joined(separator: "\n")
    }
}
