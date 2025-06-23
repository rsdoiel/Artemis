# artSocket: Minimal TCP Networking for Oberon-07

`artSocket` is a simple module for nonblocking TCP networking in Oberon-07. It provides basic socket operations for client and server applications, using a familiar pattern for those with experience in C or POSIX sockets.

## Basic Usage

### Creating a Socket

```oberon
sock := artSocket.NewSocket();
IF sock = NIL THEN
  (* handle error *)
END;
```

### Connecting as a Client

```oberon
err := artSocket.Connect(sock, "127.0.0.1", 12345);
IF (err # artSocket.Ok) & (err # artSocket.InProgress) THEN
  (* handle error *)
END;
```

### Sending and Receiving

```oberon
(* Send data *)
n := 0;
err := artSocket.Send(sock, buf, Chars.Length(buf), n);
IF n > 0 THEN
  (* sent successfully *)
END;

(* Receive data *)
n := 0;
err := artSocket.Receive(sock, buf, BUFSIZE, n);
IF n > 0 THEN
  (* got data in buf *)
END;
```

### Closing

```oberon
artSocket.Close(sock);
```

## Example: Simple Client

```oberon
IMPORT artSocket, Chars, In;

VAR sock: artSocket.Socket;
    buf: ARRAY 256 OF CHAR;
    n, err: INTEGER;

In.Open;
sock := artSocket.NewSocket();
err := artSocket.Connect(sock, "127.0.0.1", 12345);
In.Line(buf);
err := artSocket.Send(sock, buf, Chars.Length(buf), n);
err := artSocket.Receive(sock, buf, 256, n);
IF n > 0 THEN
  buf[n] := 0X;
  (* use buf *)
END;
artSocket.Close(sock);
```

## Example: Simple Server

```oberon
IMPORT artSocket, Chars;

VAR serverSock, clientSock: artSocket.Socket;
    buf: ARRAY 256 OF CHAR;
    n, err: INTEGER;

serverSock := artSocket.NewSocket();
err := artSocket.Bind(serverSock, "127.0.0.1", 12345);
err := artSocket.Listen(serverSock, 1);
clientSock := artSocket.Accept(serverSock, err);
err := artSocket.Receive(clientSock, buf, 256, n);
Chars.Cap(buf);
err := artSocket.Send(clientSock, buf, Chars.Length(buf), n);
artSocket.Close(clientSock);
artSocket.Close(serverSock);
```

## Notes
- All operations are nonblocking. Check for `WouldBlock` and retry as needed.
- Error codes are returned as integers; see the module for details.
- Only TCP/IPv4 is supported.
- This is a minimal, beta module: expect changes and improvements.

See the `ExampleSocketClient.Mod` and `ExampleSocketServer.Mod` files for more complete usage patterns.
