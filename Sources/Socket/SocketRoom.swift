import Vapor

/// Represents a room of sockets.
public final class SocketRoom<Client: SocketClient> {
	/// All of the clients in this room.
	public private(set) var clients = [UUID: Client]()
	
	/// Data which is shared between all of the clients in this room.
	public var share = Client.Share()
	
	/// Create a new room.
	public init() {}
	
	/// Register a new client from a request and socket.
	///
	/// - Parameters:
	/// 	- request: The incoming `Request`.
	/// 	- socket: The incoming `WebSocket`.
	///
	/// ```
	/// let room = SocketRoom<User>()
	/// app.webSocket(onUpgrade: room.register)
	/// ```
	public func register(request: Request, socket: WebSocket) {
		guard
			let data = request.query[String.self, at: "data"]?.data(using: .utf8),
			let query = try? decoder.decode(Client.Query.self, from: data)
		else {
			print("Bad request")
			return
		}
		
		let client = Client(
			room: self,
			socket: .init(room: self, socket: socket, query: query),
			query: query
		)
		
		clients[query.id] = client
		client.onConnect()
	}
	
	/// Remove a client from the room.
	internal func removeClient(_ id: UUID) {
		clients[id] = nil
	}
}
