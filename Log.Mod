(** Log.Mod - Basic logging module for Artemis

Copyright (C) 2025 Artemis Project

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

This module provides basic logging functionality with multiple log levels,
support for console and file output, and timestamping capabilities.
*)
MODULE Log;

IMPORT Out, extErr, Files, Strings, artClock, DStrings, Convert := extConvert, Chars;

CONST
  (* Log levels *)
  DEBUG* = 0;
  INFO* = 1; 
  WARNING* = 2;
  ERROR* = 3;
  
  (* Output destinations *)
  CONSOLE* = 0;
  FILE* = 1;
  BOTH* = 2;
  
  (* Internal constants *)
  MAX_MESSAGE_LEN = 1024;
  MAX_FILENAME_LEN = 256;

TYPE
  (* Opaque pointer - implementation details hidden from clients *)
  Logger* = POINTER TO LoggerDesc;
  LoggerDesc = RECORD  (* Not exported - opaque type *)
    level: INTEGER;        (* Minimum log level to output *)
    destination: INTEGER;  (* Where to output: CONSOLE, FILE, or BOTH *)
    filename: ARRAY MAX_FILENAME_LEN OF CHAR;
    file: Files.File;
    timestamp: BOOLEAN     (* Whether to include timestamps *)
  END;

VAR
  defaultLogger*: Logger;

(** Create a new logger with specified minimum level and destination *)
PROCEDURE New*(level, destination: INTEGER; filename: ARRAY OF CHAR): Logger;
  VAR logger: Logger;
BEGIN
  NEW(logger);
  logger.level := level;
  logger.destination := destination;
  logger.timestamp := TRUE;
  
  IF (destination = FILE) OR (destination = BOTH) THEN
    Strings.Append(filename, logger.filename);
    logger.file := Files.New(logger.filename);
    IF logger.file = NIL THEN
      (* Fallback to console if file creation fails *)
      logger.destination := CONSOLE
    ELSE
        Files.Register(logger.file)
    END
  ELSE
    logger.file := NIL
  END;
  
  RETURN logger
END New;

(** Set the minimum log level for the logger *)
PROCEDURE SetLevel*(logger: Logger; level: INTEGER);
BEGIN
  logger.level := level
END SetLevel;

(** Get the current log level for the logger *)
PROCEDURE GetLevel*(logger: Logger): INTEGER;
BEGIN
  RETURN logger.level
END GetLevel;

(** Enable or disable timestamping *)
PROCEDURE SetTimestamp*(logger: Logger; enabled: BOOLEAN);
BEGIN
  logger.timestamp := enabled
END SetTimestamp;

(** Get current timestamp setting *)
PROCEDURE GetTimestamp*(logger: Logger): BOOLEAN;
BEGIN
  RETURN logger.timestamp
END GetTimestamp;

(** Get the current destination setting *)
PROCEDURE GetDestination*(logger: Logger): INTEGER;
BEGIN
  RETURN logger.destination
END GetDestination;

(* Internal procedure to get level name as string *)
PROCEDURE GetLevelName(level: INTEGER; VAR levelName: ARRAY OF CHAR);
BEGIN
  IF level = DEBUG THEN
    Strings.Append("DEBUG", levelName)
  ELSIF level = INFO THEN
    Strings.Append("INFO", levelName)
  ELSIF level = WARNING THEN
    Strings.Append("WARNING", levelName)
  ELSIF level = ERROR THEN
    Strings.Append("ERROR", levelName)
  ELSE
    Strings.Append("UNKNOWN", levelName)
  END
END GetLevelName;

(* Internal procedure to format timestamp *)
PROCEDURE FormatTimestamp(VAR timestamp: ARRAY OF CHAR);
  VAR clock: artClock.Clock; temp: ARRAY 32 OF CHAR; ok: BOOLEAN;
BEGIN
  timestamp[0] := 0X; (* Clear the string *)
  artClock.Get(clock);
  
  (* Format: YYYY-MM-DD HH:MM:SS *)
  (* Year *)
  Convert.IntToString(clock.year, temp, ok);
  Strings.Append(temp, timestamp);
  Strings.Append("-", timestamp);
  
  (* Month *)
  IF clock.month < 10 THEN
    Strings.Append("0", timestamp)
  END;
  Convert.IntToString(clock.month, temp, ok);
  Strings.Append(temp, timestamp);
  Strings.Append("-", timestamp);
  
  (* Day *)
  IF clock.day < 10 THEN
    Strings.Append("0", timestamp)
  END;
  Convert.IntToString(clock.day, temp, ok);
  Strings.Append(temp, timestamp);
  Strings.Append(" ", timestamp);
  
  (* Hour *)
  IF clock.hour < 10 THEN
    Strings.Append("0", timestamp)
  END;
  Convert.IntToString(clock.hour, temp, ok);
  Strings.Append(temp, timestamp);
  Strings.Append(":", timestamp);
  
  (* Minute *)
  IF clock.minute < 10 THEN
    Strings.Append("0", timestamp)
  END;
  Convert.IntToString(clock.minute, temp, ok);
  Strings.Append(temp, timestamp);
  Strings.Append(":", timestamp);
  
  (* Second *)
  IF clock.second < 10 THEN
    Strings.Append("0", timestamp)
  END;
  Convert.IntToString(clock.second, temp, ok);
  Strings.Append(temp, timestamp)
END FormatTimestamp;

(* Internal procedure to write to console *)
PROCEDURE WriteToConsole(level: INTEGER; message: ARRAY OF CHAR);
BEGIN
  IF level = ERROR THEN
    extErr.String(message);
    extErr.Ln
  ELSE
    Out.String(message);
    Out.Ln
  END
END WriteToConsole;

(* Internal procedure to write to file *)
PROCEDURE WriteToFile(file: Files.File; message: ARRAY OF CHAR);
  VAR 
    rider: Files.Rider;
    newline: BYTE;
BEGIN
  IF file # NIL THEN
    Files.Set(rider, file, Files.Length(file));
    Files.WriteString(rider, message);
    newline := ORD(Chars.LF); (* Line feed *)
    Files.Write(rider, newline);
    Files.Close(file)
  END
END WriteToFile;

(** Log a message with specified level using ARRAY OF CHAR *)
PROCEDURE LogMessage*(logger: Logger; level: INTEGER; message: ARRAY OF CHAR);
  VAR 
    formattedMsg: ARRAY MAX_MESSAGE_LEN OF CHAR;
    levelName: ARRAY 16 OF CHAR;
    timestamp: ARRAY 32 OF CHAR;
BEGIN
  IF (logger = NIL) OR (level < logger.level) THEN
    (* Couldn't log. *)
  ELSE
    formattedMsg[0] := 0X; (* Clear the string *)
    
    (* Add timestamp if enabled *)
    IF logger.timestamp THEN
        FormatTimestamp(timestamp);
        Strings.Append(timestamp, formattedMsg);
        Strings.Append(" ", formattedMsg)
    END;
    
    (* Add level *)
    levelName[0] := 0X;
    GetLevelName(level, levelName);
    Strings.Append("[", formattedMsg);
    Strings.Append(levelName, formattedMsg);
    Strings.Append("] ", formattedMsg);
    
    (* Add message *)
    Strings.Append(message, formattedMsg);
    
    (* Output based on destination *)
    IF (logger.destination = CONSOLE) OR (logger.destination = BOTH) THEN
        WriteToConsole(level, formattedMsg)
    END;
    
    IF (logger.destination = FILE) OR (logger.destination = BOTH) THEN
        WriteToFile(logger.file, formattedMsg)
    END
  END;
END LogMessage;

(** Log a message with specified level using DString *)
PROCEDURE LogDString*(logger: Logger; level: INTEGER; message: DStrings.String);
  VAR chars: ARRAY MAX_MESSAGE_LEN OF CHAR; truncated: INTEGER;
BEGIN
  DStrings.ToChars(message, chars, truncated);
  LogMessage(logger, level, chars)
END LogDString;

(** Convenience procedures for common log levels *)

(** Log a debug message *)
PROCEDURE Debug*(logger: Logger; message: ARRAY OF CHAR);
BEGIN
  LogMessage(logger, DEBUG, message)
END Debug;

(** Log an info message *)
PROCEDURE Info*(logger: Logger; message: ARRAY OF CHAR);
BEGIN
  LogMessage(logger, INFO, message)
END Info;

(** Log a warning message *)
PROCEDURE Warning*(logger: Logger; message: ARRAY OF CHAR);
BEGIN
  LogMessage(logger, WARNING, message)
END Warning;

(** Log an error message *)
PROCEDURE Error*(logger: Logger; message: ARRAY OF CHAR);
BEGIN
  LogMessage(logger, ERROR, message)
END Error;

(** Convenience procedures using the default logger *)

(** Log a debug message using default logger *)
PROCEDURE DebugDefault*(message: ARRAY OF CHAR);
BEGIN
  LogMessage(defaultLogger, DEBUG, message)
END DebugDefault;

(** Log an info message using default logger *)
PROCEDURE InfoDefault*(message: ARRAY OF CHAR);
BEGIN
  LogMessage(defaultLogger, INFO, message)
END InfoDefault;

(** Log a warning message using default logger *)
PROCEDURE WarningDefault*(message: ARRAY OF CHAR);
BEGIN
  LogMessage(defaultLogger, WARNING, message)
END WarningDefault;

(** Log an error message using default logger *)
PROCEDURE ErrorDefault*(message: ARRAY OF CHAR);
BEGIN
  LogMessage(defaultLogger, ERROR, message)
END ErrorDefault;

(** Close the logger and flush any pending writes *)
PROCEDURE Close*(logger: Logger);
BEGIN
  IF (logger # NIL) & (logger.file # NIL) THEN
    Files.Close(logger.file)
  END
END Close;

BEGIN
  (* Initialize default logger to console with INFO level *)
  defaultLogger := New(INFO, CONSOLE, "")
END Log.