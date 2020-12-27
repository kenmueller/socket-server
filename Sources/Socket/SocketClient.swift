public protocol SocketClient {
	associatedtype Query: SocketQuery
	
	init(room: SocketRoom<Self>, socket: Socket, query: Query)
}
