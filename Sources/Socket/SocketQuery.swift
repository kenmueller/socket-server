import Foundation

public protocol SocketQuery: Decodable {
	var id: UUID { get }
}

public struct SocketDefaultQuery: SocketQuery {
	public let id: UUID
}
