/// Represents data shared between all clients in a room.
public protocol SocketShare {
	/// This data must be initialized with no arguments.
	init()
}

/// The default `SocketShare`, containing no data.
public struct SocketDefaultShare: SocketShare {
	public init() {}
}
