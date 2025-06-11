(** LogExtTest.Mod - Extended corner case tests for Log

Copyright (C) 2025 Artemis Project

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

This module tests additional corner cases for the Log module.
*)
MODULE LogExtTest;

IMPORT T := Tests, Log, Chars;

VAR ts: T.TestSet;

(* Test passing NIL as logger to all exported procedures *)
PROCEDURE TestNilLogger(): BOOLEAN;
VAR test: BOOLEAN;
    nilLogger: Log.Logger;
    level, dest: INTEGER;
    tsEnabled: BOOLEAN;
BEGIN
  test := TRUE;
  nilLogger := NIL;
  (* Should not crash or output *)
  Log.Debug(nilLogger, "Should not crash");
  Log.Info(nilLogger, "Should not crash");
  Log.Warning(nilLogger, "Should not crash");
  Log.Error(nilLogger, "Should not crash");
  Log.Close(nilLogger);
  level := Log.GetLevel(nilLogger);
  dest := Log.GetDestination(nilLogger);
  tsEnabled := Log.GetTimestamp(nilLogger);
  T.ExpectedInt(-1, level, "GetLevel(NIL) returns -1", test);
  T.ExpectedInt(-1, dest, "GetDestination(NIL) returns -1", test);
  T.ExpectedBool(FALSE, tsEnabled, "GetTimestamp(NIL) returns FALSE", test);
  RETURN test
END TestNilLogger;

(* Test invalid log level *)
PROCEDURE TestInvalidLogLevel(): BOOLEAN;
VAR test: BOOLEAN; logger: Log.Logger;
BEGIN
  test := TRUE;
  logger := Log.New(-1, Log.CONSOLE, "");
  T.ExpectedBool(logger = NIL, TRUE, "Logger creation fails for invalid level (low)", test);
  logger := Log.New(99, Log.CONSOLE, "");
  T.ExpectedBool(logger = NIL, TRUE, "Logger creation fails for invalid level (high)", test);
  RETURN test
END TestInvalidLogLevel;

(* Test invalid destination *)
PROCEDURE TestInvalidDestination(): BOOLEAN;
VAR test: BOOLEAN; logger: Log.Logger;
BEGIN
  test := TRUE;
  logger := Log.New(Log.INFO, -1, "");
  T.ExpectedBool(logger = NIL, TRUE, "Logger creation fails for invalid destination (low)", test);
  logger := Log.New(Log.INFO, 99, "");
  T.ExpectedBool(logger = NIL, TRUE, "Logger creation fails for invalid destination (high)", test);
  RETURN test
END TestInvalidDestination;

(* Test file creation failure (simulate with invalid filename) *)
PROCEDURE TestFileCreationFailure(): BOOLEAN;
VAR test: BOOLEAN; logger: Log.Logger;
BEGIN
  test := TRUE;
  logger := Log.New(Log.INFO, Log.FILE, "/invalid/path/shouldfail.log");
  T.ExpectedBool(logger # NIL, TRUE, "Logger fallback to console on file creation failure", test);
  Log.Info(logger, "Should fallback to console");
  Log.Close(logger);
  RETURN test
END TestFileCreationFailure;

(* Test filename truncation *)
PROCEDURE TestFilenameTruncation(): BOOLEAN;
CONST LONGNAME_LEN = Chars.MAXSTR + 10;
VAR test: BOOLEAN; logger: Log.Logger;
    longName: ARRAY LONGNAME_LEN OF CHAR; i: INTEGER;
BEGIN
  test := TRUE;
  FOR i := 0 TO LEN(longName)-2 DO longName[i] := "X" END;
  longName[LEN(longName)-1] := 0X;
  logger := Log.New(Log.INFO, Log.FILE, longName);
  T.ExpectedBool(logger # NIL, TRUE, "Logger created with long filename (should truncate)", test);
  Log.Info(logger, "Filename truncation test");
  Log.Close(logger);
  RETURN test
END TestFilenameTruncation;

(* Test toggling timestamp on and off *)
PROCEDURE TestTimestampToggle(): BOOLEAN;
VAR test: BOOLEAN; logger: Log.Logger;
BEGIN
  test := TRUE;
  logger := Log.New(Log.INFO, Log.CONSOLE, "");
  Log.Info(logger, "Timestamp should be present");
  Log.SetTimestamp(logger, FALSE);
  Log.Info(logger, "Timestamp should be absent");
  Log.SetTimestamp(logger, TRUE);
  Log.Info(logger, "Timestamp should be present again");
  Log.Close(logger);
  RETURN test
END TestTimestampToggle;

(* Test multiple loggers with different settings *)
PROCEDURE TestMultipleLoggers(): BOOLEAN;
VAR test: BOOLEAN;
    logger1, logger2: Log.Logger;
BEGIN
  test := TRUE;
  logger1 := Log.New(Log.INFO, Log.CONSOLE, "");
  logger2 := Log.New(Log.ERROR, Log.FILE, "multi.log");
  Log.Info(logger1, "Logger1 info");
  Log.Error(logger1, "Logger1 error");
  Log.Info(logger2, "Logger2 info (should not appear)");
  Log.Error(logger2, "Logger2 error");
  Log.Close(logger1);
  Log.Close(logger2);
  RETURN test
END TestMultipleLoggers;

(* Test logger reuse after close *)
PROCEDURE TestReuseAfterClose(): BOOLEAN;
VAR test: BOOLEAN; logger: Log.Logger;
BEGIN
  test := TRUE;
  logger := Log.New(Log.INFO, Log.CONSOLE, "");
  Log.Info(logger, "Before close");
  Log.Close(logger);
  Log.Info(logger, "After close (should not crash)");
  RETURN test
END TestReuseAfterClose;

(* Test empty message and exact buffer size message *)
PROCEDURE TestEmptyAndExactBuffer(): BOOLEAN;
VAR test: BOOLEAN; logger: Log.Logger;
    exactMsg: ARRAY Log.MAX_MESSAGE_LEN OF CHAR;
    i: INTEGER;
BEGIN
  test := TRUE;
  logger := Log.New(Log.INFO, Log.CONSOLE, "");
  Log.Info(logger, "");
  FOR i := 0 TO LEN(exactMsg)-2 DO exactMsg[i] := "B" END;
  exactMsg[LEN(exactMsg)-1] := 0X;
  Log.Info(logger, exactMsg);
  Log.Close(logger);
  RETURN test
END TestEmptyAndExactBuffer;

BEGIN
  T.Init(ts, "LogExtended");
  T.Add(ts, TestNilLogger);
  T.Add(ts, TestInvalidLogLevel);
  T.Add(ts, TestInvalidDestination);
  T.Add(ts, TestFileCreationFailure);
  T.Add(ts, TestFilenameTruncation);
  T.Add(ts, TestTimestampToggle);
  T.Add(ts, TestMultipleLoggers);
  T.Add(ts, TestReuseAfterClose);
  T.Add(ts, TestEmptyAndExactBuffer);
  ASSERT(T.Run(ts))
END LogExtTest.
