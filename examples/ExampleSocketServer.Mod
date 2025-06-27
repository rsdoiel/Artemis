(** ExampleSocketServer.Mod - Minimal nonblocking TCP server example

Copyright (C) 2025 Artemis Project

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

This example demonstrates a minimal TCP server using the artSocket module.
It accepts a single client, reads a line of text, capitalizes it using Chars.Cap,
and sends it back. Logging is performed using the Log module.
*)
MODULE ExampleSocketServer;

IMPORT artSleep, artSocket, Chars, Log;

CONST
  PORT = 12345;
  BUFSIZE = 256;

VAR
  serverSock, clientSock: artSocket.Socket;
  addr: ARRAY 16 OF CHAR;
  buf: ARRAY BUFSIZE OF CHAR;
  n, err: INTEGER;
  logger: Log.Logger;
  done: BOOLEAN;

PROCEDURE LogErrorWithCode(logger: Log.Logger; msg: ARRAY OF CHAR; code: INTEGER);
VAR fullMsg, numStr: ARRAY 64 OF CHAR; ok: BOOLEAN;
BEGIN
  Chars.Copy(msg, fullMsg);
  Chars.IntToString(code, numStr, ok);
  Chars.Append(numStr, fullMsg);
  Log.Error(logger, fullMsg)
END LogErrorWithCode;

PROCEDURE LogInfoWithData(logger: Log.Logger; label: ARRAY OF CHAR; data: ARRAY OF CHAR);
VAR msg: ARRAY 2*BUFSIZE OF CHAR;
BEGIN
  Chars.Copy(label, msg);
  Chars.Append(data, msg);
  Log.Info(logger, msg)
END LogInfoWithData;

BEGIN
  done := FALSE;
  logger := Log.New(Log.INFO, Log.CONSOLE, "");
  Log.Info(logger, "Starting server on port 12345");

  serverSock := artSocket.NewSocket();
  IF serverSock = NIL THEN
    Log.Error(logger, "Failed to create server socket");
    Log.Close(logger);
    done := TRUE
  END;

  IF ~done THEN
    addr := "127.0.0.1";
    err := artSocket.Bind(serverSock, addr, PORT);
    IF err # artSocket.Ok THEN
      LogErrorWithCode(logger, "Bind failed: ", err);
      artSocket.Close(serverSock);
      Log.Close(logger);
      done := TRUE
    END
  END;

  IF ~done THEN
    err := artSocket.Listen(serverSock, 1);
    IF err # artSocket.Ok THEN
      LogErrorWithCode(logger, "Listen failed: ", err);
      artSocket.Close(serverSock);
      Log.Close(logger);
      done := TRUE
    END
  END;

  IF ~done THEN
    Log.Info(logger, "Server listening on port 12345");
    REPEAT
      done := FALSE;
      clientSock := NIL;
      (* Accept loop *)
      REPEAT
        clientSock := artSocket.Accept(serverSock, err);
        IF clientSock = NIL THEN
          IF err = artSocket.WouldBlock THEN
            artSleep.Millis(100);
            (* Optionally yield or sleep here *)
          ELSE
            LogErrorWithCode(logger, "Accept failed: ", err);
            done := TRUE
          END
        END
      UNTIL (clientSock # NIL) OR done;

      IF ~done THEN
        Log.Info(logger, "Client connected");
        (* Read loop *)
        REPEAT
          n := 0;
          err := artSocket.Receive(clientSock, buf, BUFSIZE, n);
          IF n > 0 THEN
            buf[n] := 0X;
            LogInfoWithData(logger, "Received: ", buf);
            Chars.Cap(buf);
            (* Write loop *)
            REPEAT
              n := 0;
              err := artSocket.Send(clientSock, buf, Chars.Length(buf), n);
              IF n > 0 THEN
                LogInfoWithData(logger, "Sent: ", buf)
              ELSIF err = artSocket.WouldBlock THEN
                (* Optionally yield or sleep here *)
              ELSE
                LogErrorWithCode(logger, "Write failed: ", err);
                done := TRUE
              END
            UNTIL (n > 0) OR done;
          ELSIF err = artSocket.WouldBlock THEN
            (* Optionally yield or sleep here *)
          ELSIF (n = 0) & (err = artSocket.Ok) THEN
            (* Client closed connection cleanly *)
            done := TRUE
          ELSE
            LogErrorWithCode(logger, "Read failed: ", err);
            done := TRUE
          END
        UNTIL (n > 0) OR done;
      END;

      IF clientSock # NIL THEN artSocket.Close(clientSock) END;
    UNTIL FALSE
  END;
  IF serverSock # NIL THEN artSocket.Close(serverSock) END;
  Log.Info(logger, "Server shutdown");
  Log.Close(logger);
END ExampleSocketServer.
