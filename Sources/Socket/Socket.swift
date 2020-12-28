import Vapor

/// A WebSocket instance.
public final class Socket {
	/// The internal `WebSocket` instance.
	private let socket: WebSocket
	
	/// Incoming message listeners.
	private var listeners = [String: (Data) -> Void]()
	
	/// Disconnect listener.
	private var disconnectListener: (() -> Void)?
	
	/// If the socket is connected to the client or not.
	public var isConnected: Bool {
		!socket.isClosed
	}
	
	/// Create a new `Socket`.
	///
	/// - Parameters:
	/// 	- room: The `SocketRoom` this socket belongs to.
	/// 	- socket: The internal `WebSocket` instance.
	/// 	- query: The initial data sent by the client.
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
	
	/// Listen for incoming messages from the server.
	///
	/// - Parameters:
	/// 	- listener: Inputs the `Message` received from the server.
	///
	/// ```
	/// socket.on { (greeting: Greeting) in
	///     print(greeting.message)
	/// }
	/// ```
	public func on<Message: SocketMessage>(_ listener: @escaping (Message) -> Void) {
		listeners[Message.id] = { data in
			guard let message = try? decoder.decode(Message.self, from: data) else {
				return
			}
			
			listener(message)
		}
	}
	
	/// Send a message to the server.
	///
	/// - Parameters:
	/// 	- message: The `SocketMessage` to be sent.
	///
	/// ```
	/// socket.send(Message(text: "Hello, world!"))
	/// ```
	public func send<Message: SocketMessage>(_ message: Message) throws {
		socket.send([UInt8](try encoder.encode(SocketRawMessage(message))))
	}
	
	/// Attach a listener to the disconnect event.
	public func onDisconnect(_ listener: @escaping () -> Void) {
		disconnectListener = listener
	}
	
	/// Disconnect the client.
	@discardableResult
	public func disconnect() -> EventLoopFuture<Void> {
		socket.close()
	}
}

