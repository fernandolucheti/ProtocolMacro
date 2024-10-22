import ProtocolMacro

@Protocol
struct ViewModel: ViewModelProtocol {
    private var somePropertyPrivate: String = ""
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
    func functionWithReturnType() -> String { "" }
    private func testPrivate() { }
    fileprivate func testFileprivate() { }
}

extension ViewModel {
    func extensionFunctionsWilldNotBeIncluded() { }
}
