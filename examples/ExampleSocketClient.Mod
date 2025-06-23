(** ExampleSocketClient.Mod - Minimal nonblocking TCP client example

Copyright (C) 2025 Artemis Project

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

This example demonstrates a minimal TCP client using the artSocket module.
It connects to the ExampleSocketServer, sends a line of text, receives the capitalized response,
and logs all steps using the Log module.
*)
MODULE ExampleSocketClient;

IMPORT artSocket, Chars, Log, In;

CONST
  SERVER_ADDR = "127.0.0.1";
  PORT = 12345;
  BUFSIZE = 256;

VAR
  sock: artSocket.Socket;
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
  Log.Info(logger, "Starting client");

  (* Initialize input from stdin *)
  In.Open;

  sock := artSocket.NewSocket();
  IF sock = NIL THEN
    Log.Error(logger, "Failed to create socket");
    Log.Close(logger);
    done := TRUE
  END;

  IF ~done THEN
    err := artSocket.Connect(sock, SERVER_ADDR, PORT);
    IF (err # artSocket.Ok) & (err # artSocket.InProgress) THEN
      LogErrorWithCode(logger, "Connect failed: ", err);
      artSocket.Close(sock);
      Log.Close(logger);
      done := TRUE
    END
  END;

  IF ~done THEN
    (* Read a line from standard input *)
    In.Line(buf);
    LogInfoWithData(logger, "Sending: ", buf);
    n := 0;
    err := artSocket.Send(sock, buf, Chars.Length(buf), n);
    IF n > 0 THEN
      LogInfoWithData(logger, "Sent: ", "OK")
    ELSIF err = artSocket.WouldBlock THEN
      (* Optionally yield or retry here *)
    ELSE
      LogErrorWithCode(logger, "Send failed: ", err);
      done := TRUE
    END
  END;

  IF ~done THEN
    (* Read response loop *)
    REPEAT
      n := 0;
      err := artSocket.Receive(sock, buf, BUFSIZE, n);
      IF n > 0 THEN
        buf[n] := 0X;
        LogInfoWithData(logger, "Received: ", buf)
      ELSIF err = artSocket.WouldBlock THEN
        (* Optionally yield or sleep here *)
      ELSIF (n = 0) & (err = artSocket.Ok) THEN
        (* No data yet, retry *)
      ELSE
        LogErrorWithCode(logger, "Receive failed: ", err);
        done := TRUE
      END
    UNTIL (n > 0) OR done;
  END;

  IF sock # NIL THEN artSocket.Close(sock) END;
  Log.Info(logger, "Client done");
  Log.Close(logger);
END ExampleSocketClient.
