(** ExampleLog.Mod - Example usage of the Log module

Copyright (C) 2025 Artemis Project

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

This example demonstrates how to use the Log module with opaque pointers
and proper information hiding.
*)
MODULE ExampleLog;

IMPORT Log, DStrings;

PROCEDURE DemonstrateBasicLogging();
VAR 
  consoleLogger: Log.Logger;
BEGIN
  (* Create a console logger with INFO level *)
  consoleLogger := Log.New(Log.INFO, Log.CONSOLE, "");
  
  (* The LoggerDesc fields are now hidden - we use accessor procedures *)
  Log.Info(consoleLogger, "Application started");
  Log.Warning(consoleLogger, "This is a warning message");
  Log.Error(consoleLogger, "This is an error message");
  
  (* Debug messages won't appear because level is INFO *)
  Log.Debug(consoleLogger, "This debug message won't appear");
  
  (* Change log level dynamically *)
  Log.SetLevel(consoleLogger, Log.DEBUG);
  Log.Debug(consoleLogger, "Now debug messages appear");
  
  (* Clean up *)
  Log.Close(consoleLogger)
END DemonstrateBasicLogging;

PROCEDURE DemonstrateFileLogging();
VAR 
  fileLogger: Log.Logger;
  currentLevel: INTEGER;
BEGIN
  (* Create a file logger *)
  fileLogger := Log.New(Log.WARNING, Log.FILE, "application.log");
  
  (* Check current settings using accessor procedures *)
  currentLevel := Log.GetLevel(fileLogger);
  Log.Info(fileLogger, "Current log level is WARNING"); (* Won't appear *)
  Log.Warning(fileLogger, "This warning goes to file");
  Log.Error(fileLogger, "This error goes to file");
  
  (* Disable timestamps *)
  Log.SetTimestamp(fileLogger, FALSE);
  Log.Error(fileLogger, "This message has no timestamp");
  
  Log.Close(fileLogger)
END DemonstrateFileLogging;


PROCEDURE DemonstrateBothDestinations();
VAR logger: Log.Logger;
BEGIN
  (* Log to both console and file *)
  logger := Log.New(Log.DEBUG, Log.BOTH, "debug.log");
  
  Log.Info(logger, "This appears on console AND in file");
  Log.Debug(logger, "Debug info goes to both destinations");
  
  Log.Close(logger)
END DemonstrateBothDestinations;

BEGIN
  DemonstrateBasicLogging();
  DemonstrateFileLogging();
  DemonstrateBothDestinations();
END ExampleLog.
