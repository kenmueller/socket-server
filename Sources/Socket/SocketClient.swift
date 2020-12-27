public protocol SocketClient {
	typealias Room = SocketRoom<Self>
	
	associatedtype Share: SocketShare = SocketDefaultShare
	associatedtype Query: SocketQuery = SocketDefaultQuery
	
	init(room: Room, socket: Socket, query: Query)
}
