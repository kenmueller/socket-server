import Vapor

public final class SocketRoom<Client: SocketClient> {
	public private(set) var clients = [UUID: Client]()
	
	public init() {}
	
	public func register(request: Request, socket: WebSocket) {
		guard
			let data = request.query[String.self, at: "data"]?.data(using: .utf8),
			let query = try? decoder.decode(Client.Query.self, from: data)
		else {
			print("Bad request")
			return
		}
		
		clients[query.id] = .init(
			room: self,
			socket: .init(room: self, socket: socket, query: query),
			query: query
		)
	}
	
	internal func removeClient(_ id: UUID) {
		clients[id] = nil
	}
}
