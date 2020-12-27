public protocol SocketClient {
	associatedtype Share: SocketShare = SocketDefaultShare
	associatedtype Query: SocketQuery = SocketDefaultQuery
	
	init(room: SocketRoom<Self>, socket: Socket, query: Query)
}
