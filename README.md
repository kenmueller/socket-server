# Socket

Used with Vapor on the backend, in conjuction with [socket-client](https://github.com/kenmueller/socket-client)

## Install

Modify `Package.swift`

```swift
let package = Package(
    ...
    dependencies: [
        ...
        .package(name: "socket", url: "https://github.com/kenmueller/socket-server.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                ...
                .product(name: "Socket", package: "socket")
            ],
            ...
        ),
        ...
    ]
)
```

## Create a `Client`

A `Client` conforms to the `SocketClient` protocol and represents a single client in a room with other clients.

### Methods

- `init(room:socket:query:)` - Called when a client is created
- `onConnect()` - Called when a client is fully connected. You can safely use `room.clients` at this point.

### Override

- `Share` - Define the data that is shared between all clients in a room. This is stored in `room.share`.

```swift
final class User: SocketClient {
    struct Share: SocketShare {
        var leader: User?
    }
}
```

- `Query` - Define the initial data that must be sent from the client. This is included in the `init` method.

```swift
final class User: SocketClient {
    struct Query: SocketQuery {
        let id: UUID // Required. Represents the client ID.
        let name: String
	}
}
```

### Example

```swift
final class User: SocketClient {
    struct Share: SocketShare {
        var leader: User?
    }
    
    struct Query: SocketQuery {
        let id: UUID
        let name: String
    }
    
    let room: Room
    
    let id: UUID
    let name: String
    
    init(room: Room, socket: Socket, query: Query) {
        self.room = room
        
        self.id = query.id
        self.name = query.name
        
        print("\(name) joined with ID \(id)")
    }
    
    func onConnect() {
        print("\(name) successfully connected to the server")
        print("There are \(room.clients.count) users connected")
    }
}
```

## Create a `SocketRoom`

A `SocketRoom<Client>` represents a room of clients. It keeps track of all the clients and also stores shared data between each client.

### Properties

- `clients` - A read-only dictionary containing all connected clients in this room.
- `share` - Shared data between each client. This is of type `Client.Share`.

### Methods

- `register(request:socket:)` - Registers a new client. Pass this into `app.webSocket(onUpgrade:)` and everything will be handled automatically.

```swift
// configure.swift

public func configure(_ app: Application) throws {
    app.webSocket(onUpgrade: SocketRoom<User>().register)
}
```

## Create a `Message`

A `Message` conforms to the `SocketMessage` protocol and represents a message that could be sent to and from a `Socket`. Every `Message` must contain a static property `id` which differentiates it from other messages.

```swift
struct Greeting: SocketMessage {
	static let id = "greeting"
	let text: String
}
```

## Listen to incoming messages

The parameter type inside of the listener dictates what kind of message triggers the listener. If the parameter is a `Greeting`, when the client sends `Greeting` messages to the server, the listener will be called.

You can register listeners in the `init` method of a `SocketClient`.

```swift
socket.on { (greeting: Greeting) in
	print(greeting.text)
}
```

## Send messages

```swift
struct Message: SocketMessage {
	static let id = "message"
	let text: String
}

try! socket.send(Message(text: "Hello!"))
```

## Disconnect

```swift
// Check if a socket is connected
socket.isConnected

// Listen for a disconnect
socket.onDisconnect {
    print("Disconnected")
}

// Manually disconnect
socket.disconnect()
```
