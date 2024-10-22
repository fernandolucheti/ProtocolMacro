import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum ProtocolMacroError: Error {
    case notStructOrClass
}

public struct ProtocolMacro: PeerMacro {
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        
        var testableFunctions: [FunctionDeclSyntax] = []
        var testableProperties: [VariableDeclSyntax] = []
        
        let classDecl = declaration.as(ClassDeclSyntax.self)
        let structDecl = declaration.as(StructDeclSyntax.self)
        
        if classDecl == nil && structDecl == nil {
            throw ProtocolMacroError.notStructOrClass
        }
        
        let members = classDecl?.memberBlock.members ?? structDecl?.memberBlock.members ?? []
        
        for member in members {
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self),
               !funcDecl.modifiers.contains(where: { $0.name.text.contains("private") }) {
                testableFunctions.append(funcDecl)
            }
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               !varDecl.modifiers.contains(where: { $0.name.text.contains("private") }) {
                testableProperties.append(varDecl)
            }
        }
        let protocolName = "\(classDecl?.name.text ?? structDecl?.name.text ?? "")Protocol"
        var properties = ""
        var functions = ""
        
        testableFunctions.forEach { funcDecl in
            let funcName = funcDecl.name.text
            let parameters = funcDecl.signature.parameterClause.parameters.map { param in
                let paramName = param.firstName.text
                let paramType = param.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
                return "\(paramName): \(paramType)"
            }.joined(separator: ", ")
            let returnType = funcDecl.signature.returnClause?.type.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let returnSuffix = returnType.isEmpty ? "" : " -> \(returnType)"
            functions.append("func \(funcName)(\(parameters))\(returnSuffix)\n")
        }
        
        properties = testableProperties.map { varDecl in
            let propertyName = varDecl.bindings.first?.pattern.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let propertyType = varDecl.bindings.first?.typeAnnotation?.type.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Any"
            
            var hasSetter = false
            switch varDecl.bindings.first?.accessorBlock?.accessors {
            case .accessors(let accessors):
                hasSetter = accessors.contains(where: { $0.accessorSpecifier.text.contains("set") })
            case .getter:
                break
            case .none:
                hasSetter = true
            }
            let getAndSet = hasSetter ? "{ get set }" : "{ get }"
            return "var \(propertyName): \(propertyType) \(getAndSet)"
        }.joined(separator: "\n")
        
        let protocolDecl = ProtocolDeclSyntax(name: "\(raw: protocolName)",
                                              memberBlockBuilder: {
            "\(raw: [properties, functions].joined(separator: "\n"))"
        })
        return [DeclSyntax(protocolDecl)]
    }
}

@main
struct ProtocolMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ProtocolMacro.self,
    ]
}
