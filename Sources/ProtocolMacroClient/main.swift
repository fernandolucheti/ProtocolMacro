import ProtocolMacro

@Protocol
struct ViewModel: ViewModelProtocol {
    private var somePropertyPrivate: String = ""
    let someConstant: String
    var somePropertyGetAndSetImplicit: String = ""
    var somePropertyGetOnlyImplicit: String {
        ""
    }
    static var somePropertyGetOnlyExplicit: String {
        get { "" }
    }
    var somePropertyGetAndSetExplicit: String {
        get { "" }
        set { }
    }
    static func function() { }
    func functionWithParameter(in parameter: String, parameter2: String) async -> String { "" }
    func functionWithGenerics<T>(completion: @escaping (Result<T, Error>) -> Void) -> String { "" }
    func functionWithGenericsSpecifier<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) -> String { "" }
    func functionWithGenericsAndWhereClause<T, E>(completion: @escaping (Result<T, E>) -> Void) -> String where T: Decodable, E: Error { "" }
    private func testPrivate() { }
    fileprivate func testFileprivate() { }
}

@Protocol
struct ViewModelGenerics<D, E>: ViewModelGenericsProtocol where D: Decodable, E : Error {
    let someConstant: D
}

extension ViewModel {
    func extensionFunctionsWilldNotBeIncluded() { }
}
