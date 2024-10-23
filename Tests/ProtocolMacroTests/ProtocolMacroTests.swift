import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import ProtocolMacros

let testMacros: [String: Macro.Type] = [
    "Protocol": ProtocolMacro.self,
]

final class ProtocolMacroTests: XCTestCase {
    func testProtocolMacro() throws {
        let source = """
class ViewModel: ViewModelProtocol {
    private var somePropertyPrivate: String = ""
    let someConstant: Int = 0
    var somePropertyGetAndSetImplicit: String = ""
    var somePropertyGetOnlyImplicit: String {
        ""
    }
    var somePropertyGetOnlyExplicit: String {
        get { "" }
    }
    var somePropertyGetAndSetExplicit: String {
        get { "" }
        set { }
    }
    static func function() { }
    func functionWithParameter(in parameter: String, parameter2: String) -> String { "" }
    func functionWithReturnType() -> String { "" }
    private func testPrivate() { }
    fileprivate func testFileprivate() { }
}
"""
        let extensionNotIncluded = """
extension ViewModel {
    func extensionFunctionsWilldNotBeIncluded() { }
}
"""
        
        let expectedOutput = """

protocol ViewModelProtocol {
    var someConstant: Int {
        get
    }
    var somePropertyGetAndSetImplicit: String {
        get
        set
    }
    var somePropertyGetOnlyImplicit: String {
        get
    }
    var somePropertyGetOnlyExplicit: String {
        get
    }
    var somePropertyGetAndSetExplicit: String {
        get
        set
    }
    static func function()
    func functionWithParameter(in parameter: String, parameter2: String) -> String
    func functionWithReturnType() -> String
}
"""
        assertMacroExpansion(["@Protocol", source, extensionNotIncluded].joined(separator: "\n"),
                             expandedSource: [source, expectedOutput, extensionNotIncluded].joined(separator: "\n"),
                             macros: testMacros,
                             indentationWidth: .spaces(4))
    }
    
    func testGenericsWhereClause() throws {
        let source = """
struct ViewModel<D, E>: ViewModelProtocol where E: Error, D: Decodable {
    let someConstant: D
    func functionWithGenericsAndWhereClause<T, E>(completion: @escaping (Result<T, E>) -> Void) -> String where T: Decodable, E: Error { "" }
}
"""
        
        let expectedOutput = """

protocol ViewModelProtocol {
    associatedtype D: Decodable
    associatedtype E: Error
    var someConstant: D {
        get
    }
    func functionWithGenericsAndWhereClause<T, E>(completion: @escaping (Result<T, E>) -> Void) -> String where T: Decodable, E: Error
}
"""
        
        assertMacroExpansion(["@Protocol", source].joined(separator: "\n"),
                             expandedSource: [source, expectedOutput].joined(separator: "\n"),
                             macros: testMacros,
                             indentationWidth: .spaces(4))
    }
    
    func testGenerics() throws {
        let source = """
struct ViewModel<D: Decodable, E: Error> {
    let someConstant: D
    func functionWithGenerics<T>(completion: @escaping (Result<T, Error>) -> Void) -> String { "" }
    func functionWithGenericsSpecifier<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) -> String { "" }
}
"""
        
        let expectedOutput = """

protocol ViewModelProtocol {
    associatedtype D: Decodable
    associatedtype E: Error
    var someConstant: D {
        get
    }
    func functionWithGenerics<T>(completion: @escaping (Result<T, Error>) -> Void) -> String
    func functionWithGenericsSpecifier<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) -> String
}
"""
        
        assertMacroExpansion(["@Protocol", source].joined(separator: "\n"),
                             expandedSource: [source, expectedOutput].joined(separator: "\n"),
                             macros: testMacros,
                             indentationWidth: .spaces(4))
    }
    
    func testAsync() throws {
        let source = """
struct ViewModel {
    func asyncFunction() async -> String { "" }
}
"""
        
        let expectedOutput = """

protocol ViewModelProtocol {

    func asyncFunction() async -> String
}
"""
        
        assertMacroExpansion(["@Protocol", source].joined(separator: "\n"),
                             expandedSource: [source, expectedOutput].joined(separator: "\n"),
                             macros: testMacros,
                             indentationWidth: .spaces(4))
    }
}
