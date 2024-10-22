
@attached(peer, names: suffixed(Protocol))
public macro Protocol() = #externalMacro(module: "ProtocolMacros", type: "ProtocolMacro")
