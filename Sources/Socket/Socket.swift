import Vapor

public final class Socket {
	private let socket: WebSocket
	
	private var listeners = [String: (Data) -> Void]()
	private var disconnectListener: (() -> Void)?
	
	public var isConnected: Bool {
		!socket.isClosed
	}
	
	internal init<Client: SocketClient>(room: SocketRoom<Client>, socket: WebSocket, query: Client.Query) {
		self.socket = socket
		
		socket.onBinary { _, data in
			guard
				let message = try? decoder.decode(SocketRawMessage.self, from: data),
				let listener = self.listeners[message.id],
				let data = message.data.data(using: .utf8)
			else { return }
			
			listener(data)
		}
		
		socket.onClose.whenSuccess {
			room.removeClient(query.id)
			self.disconnectListener?()
		}
	}
	
	deinit {
		disconnect()
	}
	
	public func on<Message: SocketMessage>(_ listener: @escaping (Message) -> Void) {
		listeners[Message.id] = { data in
			guard let message = try? decoder.decode(Message.self, from: data) else {
				return
			}
			
			listener(message)
		}
	}
	
	public func send<Message: SocketMessage>(_ message: Message) throws {
		socket.send([UInt8](try encoder.encode(SocketRawMessage(message))))
	}
	
	public func onDisconnect(_ listener: @escaping () -> Void) {
		disconnectListener = listener
	}
	
	@discardableResult
	public func disconnect() -> EventLoopFuture<Void> {
		socket.close()
	}
}

