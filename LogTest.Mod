(** LogTest.Mod - Test module for Log

Copyright (C) 2025 Artemis Project

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

This module tests the Log module functionality and demonstrates
proper usage of the opaque Logger type.
*)
MODULE LogTest;

IMPORT T := Tests, Log, DStrings;

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

PROCEDURE TestDefaultLogger(): BOOLEAN;
VAR test: BOOLEAN;
BEGIN
  test := TRUE;
  
  (* Test default logger convenience methods *)
  Log.InfoDefault("Testing default logger info");
  Log.WarningDefault("Testing default logger warning");
  Log.ErrorDefault("Testing default logger error");
  Log.DebugDefault("Testing default logger debug");
  
  RETURN test
END TestDefaultLogger;

PROCEDURE TestDStringLogging(): BOOLEAN;
VAR 
  test: BOOLEAN;
  logger: Log.Logger;
  message: DStrings.String;
BEGIN
  test := TRUE;
  
  logger := Log.New(Log.INFO, Log.CONSOLE, "");
  
  (* Test DString logging *)
  DStrings.Init("This is a DString message", message);
  Log.LogDString(logger, Log.INFO, message);
  
  Log.Close(logger);
  
  RETURN test
END TestDStringLogging;

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

BEGIN
  T.Init(ts, "Log");
  T.Add(ts, TestLoggerCreation);
  T.Add(ts, TestLogLevels);
  T.Add(ts, TestDefaultLogger);
  T.Add(ts, TestDStringLogging);
  T.Add(ts, TestFileLogging);
  ASSERT(T.Run(ts))
END LogTest.
