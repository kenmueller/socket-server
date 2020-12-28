import Foundation

/// The initial data sent from the client to the server.
/// Must contain an `id` which represents the client ID.
public protocol SocketQuery: Decodable {
	/// The client ID.
	var id: UUID { get }
}

/// The default `SocketQuery`, containing only the client ID.
public struct SocketDefaultQuery: SocketQuery {
	public let id: UUID
}
