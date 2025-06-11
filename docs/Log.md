# Artemis Log Module

A simple, flexible logging module for Oberon-07 that makes it easy to add logging to your applications.

## What It Does

The Log module provides basic logging functionality with multiple log levels, support for both console and file output, and automatic timestamping. It's designed to be lightweight, with no hidden behavior.

## Quick Start

```oberon
IMPORT Log;

(* Create your logger *)
VAR logger: Log.Logger;
logger := Log.New(Log.DEBUG, Log.CONSOLE, "");
Log.Info(logger, "Custom logger message");
Log.Close(logger);
```

## Key Features

- **Multiple Log Levels**: DEBUG, INFO, WARNING, ERROR with automatic filtering
- **Flexible Output**: Log to console, file, or both simultaneously  
- **Timestamping**: Automatic timestamps that can be toggled on/off
- **String Support**: Works with both `ARRAY OF CHAR` and `DString` types
- **Information Hiding**: Uses opaque pointers to hide implementation details

## Log Levels

- `DEBUG` (0): Detailed diagnostic information
- `INFO` (1): General informational messages  
- `WARNING` (2): Something unexpected but not critical
- `ERROR` (3): Error conditions that need attention

Messages below your logger's minimum level are automatically filtered out.

## Output Destinations

- `CONSOLE`: Output to standard output (INFO/DEBUG/WARNING) or stderr (ERROR)
- `FILE`: Write to a specified log file
- `BOTH`: Send messages to both console and file

## Example Usage

```oberon
VAR 
  consoleLogger, fileLogger, bothLogger: Log.Logger;

(* Console-only logger *)
consoleLogger := Log.New(Log.INFO, Log.CONSOLE, "");

(* File-only logger *)
fileLogger := Log.New(Log.WARNING, Log.FILE, "app.log");

(* Both console and file *)
bothLogger := Log.New(Log.DEBUG, Log.BOTH, "debug.log");

(* Log some messages *)
Log.Info(consoleLogger, "App initialized");
Log.Warning(fileLogger, "Config file not found, using defaults");
Log.Debug(bothLogger, "Processing user request");

(* Clean up *)
Log.Close(consoleLogger);
Log.Close(fileLogger);  
Log.Close(bothLogger);
```

## Timestamps

All messages include timestamps by default in `YYYY-MM-DD HH:MM:SS` format. You can disable them if needed:

```oberon
Log.SetTimestamp(logger, FALSE);
Log.Info(logger, "This message has no timestamp");
```


## Error Handling

If file creation fails, file loggers automatically fall back to console output. The module handles NIL loggers gracefully and filters messages below the minimum log level without errors.

This makes the Log module robust and safe to use in any situation.
