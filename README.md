# ProtocolMacro
A macro that produces a protocol based on a class/struct public interface

## Usage
 1 - add ProtocolMacro as a dependency  
 2 - import ProtocolMacro  
 3 - mark your class or struct with the macro @Protocol  
 4 - Add conformance to generated protocol (its name is your Type suffixed by 'Protocol'): {YourTypeHere}Protocol  

## example
```swift
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
```

## auto-generated code: 
```swift
protocol ViewModelProtocol {
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
    func functionWithReturnType() -> String
}
```
