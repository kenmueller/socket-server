import Vapor

public final class SocketRoom<Client: SocketClient> {
	public private(set) var clients = [UUID: Client]()
	public var share = Client.Share()
	
	public init() {}
	
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
	
	internal func removeClient(_ id: UUID) {
		clients[id] = nil
	}
}
