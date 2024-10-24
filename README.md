# ProtocolMacro
A macro that produces a protocol based on a class/struct non private interface

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
    var someProperty: String = ""
    var someGetOnlyProperty: String {
        ""
    }
    private var privatePropertiesNotIncluded: String = ""
    func function() { }
    func functionWithReturnType() -> String { "" }
    private func privateFunctionsNotIncluded() { }
    fileprivate func fileprivateFunctionsNotIncluded() { }
}

extension ViewModel {
    func extensionFunctionsNotIncluded() { }
}
```

## auto-generated code: 
```swift
protocol ViewModelProtocol {
    var someProperty: String {
        get
        set
    }
    var someGetOnlyProperty: String {
        get
    }
    func function()
    func functionWithReturnType() -> String
}
```
