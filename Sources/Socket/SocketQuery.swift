import Foundation

public protocol SocketQuery: Decodable {
	var id: UUID { get }
}
