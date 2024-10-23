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
    func function() { }
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
    func function()
    func functionWithParameter(in parameter: String, parameter2: String) -> String
    func functionWithReturnType() -> String
}
"""
        assertMacroExpansion(["@Protocol", source, extensionNotIncluded].joined(separator: "\n"),
                             expandedSource: [source, expectedOutput, extensionNotIncluded].joined(separator: "\n"),
                             macros: testMacros,
                             indentationWidth: .spaces(4))
    }
}
