//
//  ProtocolMacro.swift
//  ProtocolMacro
//
//  Created by Fernando Lucheti on 22/10/24.
//

/// A peer macro that generates a protocol including non private members of any class or struct.
///
/// The generated protocol is named by the type name followed with a "Protocol" suffix.
///
/// Example usage:
///
/// ```swift
/// import ProtocolMacro
/// @Protocol
/// struct ViewModel: ViewModelProtocol {
///     var someProperty: String = ""
///     private var privatePropertiesNotIncluded: String = ""
///     func function() { }
///     private func privateFunctionsNotIncluded() { }
/// }
///
/// protocol ViewModelProtocol {
///     var someProperty: String {
///         get
///         set
///     }
///     func function()
/// }
/// ```
@attached(peer, names: suffixed(Protocol))
public macro Protocol() = #externalMacro(module: "ProtocolMacros", type: "ProtocolMacro")
