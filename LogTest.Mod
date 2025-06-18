(** LogTest.Mod - Test module for Log

Copyright (C) 2025 Artemis Project

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

This module tests the Log module functionality and demonstrates
proper usage of the opaque Logger type.
*)
MODULE LogTest;

IMPORT T := Tests, Log, Chars;

CONST 
  OVERLONG_MSG_LEN = Chars.MAXSTR + 10;

VAR 
  ts: T.TestSet;

PROCEDURE TestLoggerCreation(): BOOLEAN;
VAR 
  test: BOOLEAN;
  logger: Log.Logger;
  level, destination: INTEGER;
  timestampEnabled: BOOLEAN;
BEGIN
  test := TRUE;
  
  (* Test creating a console logger *)
  logger := Log.New(Log.INFO, Log.CONSOLE, "");
  T.ExpectedBool(logger # NIL, TRUE, "Logger created successfully", test);
  
  (* Test accessor procedures - information hiding in action *)
  level := Log.GetLevel(logger);
  T.ExpectedInt(Log.INFO, level, "GetLevel returns correct value", test);
  
  destination := Log.GetDestination(logger);
  T.ExpectedInt(Log.CONSOLE, destination, "GetDestination returns correct value", test);
  
  timestampEnabled := Log.GetTimestamp(logger);
  T.ExpectedBool(TRUE, timestampEnabled, "Timestamp enabled by default", test);
  
  (* Test setting properties *)
  Log.SetLevel(logger, Log.WARNING);
  level := Log.GetLevel(logger);
  T.ExpectedInt(Log.WARNING, level, "SetLevel updates correctly", test);
  
  Log.SetTimestamp(logger, FALSE);
  timestampEnabled := Log.GetTimestamp(logger);
  T.ExpectedBool(FALSE, timestampEnabled, "SetTimestamp updates correctly", test);
  
  Log.Close(logger);
  
  RETURN test
END TestLoggerCreation;

PROCEDURE TestLogLevels(): BOOLEAN;
VAR 
  test: BOOLEAN;
  logger: Log.Logger;
BEGIN
  test := TRUE;
  
  (* Create logger with DEBUG level *)
  logger := Log.New(Log.DEBUG, Log.CONSOLE, "");
  
  (* Test that all levels work *)
  Log.Debug(logger, "Debug message");
  Log.Info(logger, "Info message");
  Log.Warning(logger, "Warning message");
  Log.Error(logger, "Error message");
  
  (* Set higher level and test filtering *)
  Log.SetLevel(logger, Log.ERROR);
  
  (* These should be filtered out (not cause crashes) *)
  Log.Debug(logger, "Should not appear");
  Log.Info(logger, "Should not appear");
  Log.Warning(logger, "Should not appear");
  
  (* This should appear *)
  Log.Error(logger, "This should appear");
  
  Log.Close(logger);
  
  RETURN test
END TestLogLevels;

PROCEDURE TestFileLogging(): BOOLEAN;
VAR 
  test: BOOLEAN;
  logger: Log.Logger;
BEGIN
  test := TRUE;
  
  (* Test file logging - should fallback to console if file creation fails *)
  logger := Log.New(Log.INFO, Log.FILE, "test.log");
  T.ExpectedBool(logger # NIL, TRUE, "File logger created", test);
  
  Log.Debug(logger, "This won't show up");
  Log.Info(logger, "Test file logging message");
  Log.Warning(logger, "Test file logging message");
  Log.Error(logger, "Test file logging message");
  Log.Close(logger);
  
  RETURN test
END TestFileLogging;

PROCEDURE TestTruncation(): BOOLEAN;
VAR
  test: BOOLEAN;
  logger: Log.Logger;
  longMsg: ARRAY OVERLONG_MSG_LEN OF CHAR; (* Longer than MAX_MESSAGE_LEN *)
  i: INTEGER;
BEGIN
  test := TRUE;
  FOR i := 0 TO LEN(longMsg)-2 DO
    longMsg[i] := "A"
  END;
  longMsg[LEN(longMsg)-1] := 0X;

  logger := Log.New(Log.INFO, Log.CONSOLE, "");
  Log.Info(logger, longMsg);
  Log.Close(logger);

  (* Manual check: No crash, output is truncated, string is valid *)
  RETURN test
END TestTruncation;

(* Corner cases and extended tests *)

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
  T.Init(ts, "Log");
  T.Add(ts, TestLoggerCreation);
  T.Add(ts, TestLogLevels);
  T.Add(ts, TestFileLogging);
  T.Add(ts, TestTruncation);
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
END LogTest.
