/// Represents a client.
public protocol SocketClient {
	/// The `SocketRoom` which contains this client.
	typealias Room = SocketRoom<Self>
	
	/// The shared data type stored in the room.
	associatedtype Share: SocketShare = SocketDefaultShare
	
	/// The initial data type sent by the client.
	associatedtype Query: SocketQuery = SocketDefaultQuery
	
	/// Initialize a new `SocketClient`.
	///
	/// `room.clients` does not contain this client at this point.
	///
	/// - Parameters:
	/// 	- room: The surrounding room.
	/// 	- socket: The `Socket` instance attached to this client.
	/// 	- query: The initial data sent by the client.
	init(room: Room, socket: Socket, query: Query)
	
	/// Called when the client successfully connects to the server.
	/// The `clients` property in the room is populated with this client by the time `onConnect` is called.
	func onConnect()
}
